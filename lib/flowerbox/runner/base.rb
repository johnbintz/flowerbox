module Flowerbox
  module Runner
    class Base
      attr_reader :sprockets, :spec_files, :options, :time

      attr_accessor :results

      MAX_COUNT = 50

      class RunnerDiedError < StandardError ; end

      def initialize
        @results = ResultSet.new
        @started = false
      end

      def started?
        @started
      end

      def ensure_alive
        while @count < MAX_COUNT && !finished?
          @count += 1 if @timer_running
          sleep 0.1
        end

        if !finished?
          puts "Something died hard. Here are the tests that did get run before Flowerbox died.".foreground(:red)
          puts tests.flatten.join("\n").foreground(:red)
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
        setup(*args)

        @count = 0
        @timer_running = true

        puts "Flowerbox running your #{Flowerbox.test_environment.name} tests on #{console_name}..."

        server.start

        yield

        server.stop

        @results
      end

      def configured?
        true
      end

      def configure
      end

      def pause_timer
        @timer_running = false
        @count = 0
      end

      def unpause_timer
        @timer_running = true
      end

      def debug?
        options[:debug] == true
      end

      def ensure_configured!
        if !configured?
          puts "#{console_name} is not configured for this project, configuring now..."
          configure
        end
      end

      def type
        self.class.name.to_s.split('::').last.downcase.to_sym
      end

      def start_test_environment
        Flowerbox.test_environment.start
      end

      def time=(time)
        @results.time = time
      end

      def did_start!
        @started = true
      end

      def server
        return @server if @server

        server_options = { :app => Flowerbox::Rack }
        server_options[:logging] = true if options[:verbose_server]
        server_options[:port] = Flowerbox.port

        @server = Flowerbox::Server.new(server_options)
        Flowerbox::Rack.runner = self
        Flowerbox::Rack.sprockets = @sprockets

        @server
      end

      def log(message)
        puts message
      end

      def tests
        @tests ||= []
      end

      def add_tests(new_tests)
        tests << new_tests

        puts new_tests.flatten if options[:verbose_server]

        @count = 0
      end

      def failures
        @failures ||= []
      end

      def add_results(test_results)
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

      def finish!(time)
        @time = time

        @finished = true
      end

      def finished?
        @finished
      end

      def ping
        @count = 0
      end

      private
      def result_set_from_test_results(test_results)
        ResultSet.from_results(test_results, options.merge(:runner => name))
      end
    end
  end
end

