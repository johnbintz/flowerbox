require 'rack'
require 'net/http'
require 'socket'
require 'rack/builder'
require 'thin'
require 'em-websocket'
require 'json'
require 'forwardable'

module Flowerbox
  class Server
    attr_reader :options
    attr_accessor :runner

    class MissingRackApp < StandardError ; end
    class ServerDiedError < StandardError ; end

    extend Forwardable

    def_delegators :@server_thread, :alive?

    def initialize(runner, options = {})
      @runner = runner
      @options = { :logging => false }.merge(options || {})
    end

    def app
      options[:app] || raise(MissingRackApp.new)
    end

    def rack_app
      Thin::Logging.silent = !options[:logging]

      rack_app = app

      if options[:logging]
        rack_app = ::Rack::Builder.new do
          use ::Rack::CommonLogger, STDOUT
          run app
        end
      end

      rack_app
    end

    def websocket_app(ws)
      ws.onmessage { |message|
        command, data = JSON.parse(message)

        output = runner.send(command, [ data ].flatten)

        if command == 'load'
          ws.send(output)
        else
          ws.send("ok")
        end
      }
    end

    def start
      @server_thread = Thread.new do
        begin
          server_options = { :Port => port, :Host => interface }

          EventMachine.run do
            EventMachine::WebSocket.start(:host => interface, :port => port + 1, &method(:websocket_app))

            ::Rack::Handler::Thin.run(rack_app, server_options) do |server|
              Thread.current[:server] = server

              trap('QUIT') { server.stop }
            end
          end
        rescue => e
          @server_thread[:exception] = e

          raise e
        end
      end

      while !@server_thread[:server] && alive?
        sleep 0.1
      end

      if @server_thread[:exception]
        raise @server_thread[:exception]
      else
        raise ServerDiedError.new if !alive?
      end
    end

    def stop
      if @server_thread
        @server_thread[:server].stop rescue nil
        EventMachine.stop_event_loop
        @server_thread.kill

        wait_for_server_to_stop
      end
    end

    def interface
      options[:interface] || '0.0.0.0'
    end

    def port
      return @port if @port

      if options[:port]
        return @port = options[:port]
      end

      attempts = 20

      begin
        try_server_to_something(nil, Proc.new { |port| @port = port }, (random_port / 2).floor * 2)

        attempts -= 1
      end while !@port and attempts != 0

      raise StandardError.new("can't start server") if attempts == 0

      @port
    end

    def address
      @address ||= "http://#{interface}:#{port}/"
    end

    private
    def wait_for_server_to_start
      started = false

      while !started do
        try_server_to_something(Proc.new { started = true })
      end
    end

    def wait_for_server_to_stop
      while alive? do
        try_server_to_something(nil, Proc.new { return })
      end
    end

    def try_server_to_something(success, failure = nil, current_port = port)
      begin
        connect_interface = '127.0.0.1' if interface == '0.0.0.0'

        socket = TCPSocket.new(connect_interface, current_port)
        socket.close

        success.call(current_port) if success
      rescue => e
        case e
        when Errno::ECONNREFUSED, Errno::ECONNRESET
          failure.call(current_port) if failure
        else
          raise e
        end
      end

      sleep 0.1
    end

    def random_port
      25000 + Kernel.rand(1000)
    end
  end
end

