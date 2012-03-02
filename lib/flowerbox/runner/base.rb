module Flowerbox
  module Runner
    class Base
      attr_reader :sprockets

      attr_accessor :time, :results

      def run(sprockets)
        @sprockets = sprockets

        puts "Flowerbox running your #{Flowerbox.test_environment.name} tests on #{name}..."

        server.start

        yield

        server.stop

        puts

        failures.each do |failure_set|
          if failure_set.first['splitName']
            puts failure_set.first['splitName'].join(' ')
          end

          failure_set.each do |failure|
            case failure['trace']['stack']
            when String
              # exception
              puts failure['trace']['stack']
            else
              # failed test
              puts %{#{failure['message']} (#{failure['trace']['stack'].first})}
            end
          end

          puts
        end

        puts "#{total_count} tests, #{failure_count} failures, #{time.to_f / 1000} sec"

        if failures.length == 0
          $?.exitstatus
        else
          1
        end
      end

      def type
        self.class.name.to_s.split('::').last.downcase.to_sym
      end

      def start_test_environment
        Flowerbox.test_environment.start_for(self)
      end

      def server
        return @server if @server

        @server = Flowerbox::Delivery::Server.new(:app => Flowerbox::Rack)
        Flowerbox::Rack.runner = self

        @server
      end

      def log(message)
        puts message
      end

      def tests
        @tests ||= []
      end

      def failures
        @failures ||= []
      end

      def add_failures(test_failures)
        if test_failures.length == 0
          print '.'
        else
          print 'F'
        end

        $stdout.flush

        failures << test_failures
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
    end
  end
end

