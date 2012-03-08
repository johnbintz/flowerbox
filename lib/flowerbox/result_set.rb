module Flowerbox
  class ResultSet
    attr_reader :results, :options

    attr_accessor :time

    def self.from_results(results, options)
      results = results['items_'].collect do |result|
        if name = result['splitName']
          case result['passed_']
          when true
            Success.new(name, result['message'])
          else
            Failure.new(name, result['message'], result['trace']['stack'].first)
          end
        else
          Exception.new(result.first['trace']['stack'])
        end
      end.flatten

      results.each { |result| result.runners << options[:runner] }

      new(results, options)
    end

    def self.for(runner)
      new(results, :runner => runner)
    end

    def initialize(results = [], options = {})
      @results, @options = results, options
    end

    def <<(other)
      other.results.each do |other_result|
        if existing_result = results.find { |result| result == other_result }
          existing_result.runners << other_result.runners
        else
          results << other_result
        end
      end
    end

    def exitstatus
      @results.empty? ? 0 : 1
    end

    def print
      gathered_results.each(&:print)

      puts "#{total_tests} total, #{total_failures} failures, #{time} secs."
    end

    def total_tests
      results.length
    end

    def total_failures
      results.reject(&:success?).length
    end

    def print_progress
      @results.each { |result| result.print_progress ; $stdout.flush }
    end

    def gathered_results
      return @gathered_results if @gathered_results

      @gathered_results = []

      results.each do |result|
        case result
        when Flowerbox::Exception
          @gathered_results << result
        when Flowerbox::Failure
          if !(gathered_result = @gathered_results.find { |g| g.name == result.name })
            gathered_result = GatheredResult.new(result.name)

            @gathered_results << gathered_result
          end

          gathered_result << result
        end
      end

      @gathered_results
    end
  end
end

