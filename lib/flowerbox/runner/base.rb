module Flowerbox
  module Runner
    class Base
      attr_reader :sprockets, :spec_files, :options

      attr_accessor :results

      def initialize
        @results = ResultSet.new
      end

      def run(sprockets, spec_files, options)
        @sprockets, @spec_files, @options = sprockets, spec_files, options

        puts "Flowerbox running your #{Flowerbox.test_environment.name} tests on #{console_name}..."

        server.start

        yield

        server.stop

        puts
        puts

        @results
      end

      def configured?
        true
      end

      def configure
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
        Flowerbox.test_environment.start_for(self)
      end

      def time=(time)
        p time
        @results.time = time
      end

      def server
        return @server if @server

        server_options = { :app => Flowerbox::Rack }
        server_options[:logging] = true if options[:verbose]

        @server = Flowerbox::Delivery::Server.new(server_options)
        Flowerbox::Rack.runner = self

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
      end

      def failures
        @failures ||= []
      end

      def add_results(test_results)
        results = result_set_from_test_results(test_results)

        results.print_progress

        @results << results
      end

      def total_count
        @tests.length
      end

      def failure_count
        @failures.length
      end

      def finish!(time)
        @time = time

        @finished = true
      end

      def finished?
        @finished
      end

      private
      def result_set_from_test_results(test_results)
        ResultSet.from_results(test_results.first, options.merge(:runner => name))
      end
    end
  end
end

