require 'thread'

module Flowerbox
  module Runner
    class Base
      attr_reader :sprockets, :spec_files, :options, :time

      attr_accessor :results

      MAX_COUNT = 50

      class RunnerDiedError < StandardError ; end

      def self.mutex
        @mutex ||= Mutex.new
      end

      def initialize
        @results = ResultSet.new
        @started = false
      end

      def started?
        @started
      end

      def starting(*args)
        @started = true
      end

      def reporters
        Flowerbox.reporters
      end

      def load(file)
        sprockets.find_asset(file.first, :bundle => false).body
      end

      def instrument(data)
        results = []

        data.flatten.first.each do |filename, lines|
          results += lines.reject { |line| line == nil }
        end

        visited = results.find_all { |result| result == 1 }.length

        Flowerbox.notify "Coverage: %d/%d lines (%0.2f%% of instrumented code)" % [ visited, results.length, (visited.to_f / results.length.to_f) * 100 ]
      end

      def ensure_alive
        while @count < MAX_COUNT && !finished?
          @count += 1 if @timer_running
          sleep 0.1
        end

        if !finished?
          Flowerbox.notify "Something died hard. Here are the tests that did get run before Flowerbox died.".foreground(:red)
          Flowerbox.notify tests.flatten.join("\n").foreground(:red)
          server.stop
          Flowerbox.server = nil

          raise RunnerDiedError.new
        end
      end

      def setup(sprockets, spec_files, options)
        @sprockets, @spec_files, @options = sprockets, spec_files, options

        Flowerbox.test_environment.runner = self
        Flowerbox.test_environment.inject_into(sprockets)
        Flowerbox.additional_files.each { |file| sprockets.add(file) }
      end

      def run(*args)
        self.class.mutex.synchronize do
          setup(*args)

          @count = 0
          @timer_running = true

          reporters.start("Flowerbox running your #{Flowerbox.test_environment.name} tests on #{console_name}...")

          attempts = 3

          require 'flowerbox/server'

          while true
            begin
              server.start

              break
            rescue Flowerbox::Server::ServerDiedError
              attempts -= 1
              raise RunnerDiedError.new if attempts == 0

              Flowerbox.server = nil
            end
          end

          yield

          server.stop
        end

        @results
      rescue => e
        case e
        when ExecJS::RuntimeError, ExecJS::ProgramError, Sprockets::FileNotFound
          handle_coffeescript_compilation_error(e)
        else
          raise e
        end
      end

      def configured?
        true
      end

      def configure ; end

      def pause_timer(*args)
        @timer_running = false
        @count = 0
      end

      def unpause_timer(*args)
        @timer_running = true
      end

      def debug?
        options[:debug] == true
      end

      def ensure_configured!
        if !configured?
          Flowerbox.notify "#{console_name} is not configured for this project, configuring now..."
          configure
        end
      end

      def type
        self.class.name.to_s.split('::').last.downcase.to_sym
      end

      def start_test_environment
        Flowerbox.test_environment.start
      rescue ExecJS::ProgramError => e
        handle_coffeescript_compilation_error(e)
      end

      def time=(time)
        @results.time = time
      end

      def server
        require 'flowerbox/rack'

        if Flowerbox.server
          Flowerbox.server.runner = self
          Flowerbox.server.app.runner = self
          Flowerbox.server.app.sprockets = sprockets
          return Flowerbox.server
        end

        require 'flowerbox/server'

        server_options = { :app => Flowerbox::Rack.new(self, sprockets) }
        server_options[:logging] = true if options[:verbose_server]
        server_options[:port] = Flowerbox.port

        Flowerbox.server = Flowerbox::Server.new(self, server_options)
      end

      def log(message)
        reporters.log(message)
      end

      def tests
        @tests ||= []
      end

      def start_test(new_tests)
        tests << new_tests

        Flowerbox.notify(new_tests.flatten) if options[:verbose_server]

        @count = 0
      end

      def failures
        @failures ||= []
      end

      def finish_test(test_results)
        results = result_set_from_test_results(test_results)

        results.print_progress

        @count = 0

        @results << results
      end

      def total_count
        @tests.length
      end

      def failure_count
        @failures.length
      end

      def time
        @time ||= 0
      end

      def results(time)
        @time = time.first

        @finished = true
      end

      def finished?
        @finished
      end

      def ping
        @count = 0
      end

      def handle_coffeescript_compilation_error(exception)
        Flowerbox.notify(exception.message.foreground(:red))
        @finished = true

        raise RunnerDiedError.new(exception.message)
      end

      private
      def result_set_from_test_results(test_results)
        ResultSet.from_results(test_results, options.merge(:runner => name))
      end
    end
  end
end

