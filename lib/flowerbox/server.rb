require 'rack'
require 'net/http'
require 'socket'
require 'rack/builder'
require 'thin'

module Flowerbox
  class Server
    attr_reader :options

    class MissingRackApp < StandardError ; end
    class ServerDiedError < StandardError ; end

    def initialize(options = {})
      @options = { :logging => false }.merge(options || {})
    end

    def app
      options[:app] || raise(MissingRackApp.new)
    end

    def start
      @server_thread = Thread.new do
        server_options = { :Port => port, :Host => interface }

        Thin::Logging.silent = !options[:logging]

        rack_app = app

        if options[:logging]
          rack_app = ::Rack::Builder.new do
            use ::Rack::CommonLogger, STDOUT
            run app
          end
        end

        ::Rack::Handler::Thin.run(rack_app, server_options) do |server|
          Thread.current[:server] = server

          trap('QUIT') { server.stop }
        end
      end

      while !@server_thread[:server] && @server_thread.alive?
        sleep 0.1
      end

      raise ServerDiedError.new if !@server_thread[:server].running?
    end

    def stop
      if @server_thread
        @server_thread[:server].stop

        wait_for_server_to_stop
      end
    end

    def interface
      options[:interface] || '0.0.0.0'
    end

    def port
      return @port if @port ||= options[:port]

      attempts = 20

      begin
        attempts -= 1

        current_port = random_port

        begin
          socket = TCPSocket.new(interface, current_port)
          socket.close
        rescue Errno::ECONNREFUSED => e
          @port = current_port
        end
      end while !@port and attempts > 0

      raise StandardError.new("can't start server") if attempts == 0

      @port
    end

    def address
      "http://#{interface}:#{port}/"
    end

    def alive?
      @server_thread.alive?
    end

    private
    def wait_for_server_to_start
      while true do
        begin
          connect_interface = '127.0.0.1' if interface == '0.0.0.0'

          TCPSocket.new(connect_interface, port)
          break
        rescue Errno::ECONNREFUSED => e
        end

        sleep 0.1
      end
    end

    def wait_for_server_to_stop
      while alive? do
        begin
          connect_interface = '127.0.0.1' if interface == '0.0.0.0'

          socket = TCPSocket.new(connect_interface, port)
          socket.close
        rescue Errno::ECONNREFUSED => e
          return
        end

        sleep 0.1
      end
    end

    def random_port
      25000 + Kernel.rand(1000)
    end
  end
end

