module Flowerbox
  class ResultSet
    attr_reader :results, :options

    attr_accessor :time

    def self.from_results(results, options)
      results = results.collect do |result|
        result['runner'] = options[:runner]

        if name = result['name']
          Flowerbox::Result.for(result['source'], result['status']).new(result)
        else
          Flowerbox::Result::Exception.new(result)
        end
      end.flatten

      new(results, options)
    end

    def self.for(runner)
      new(results, :runner => runner)
    end

    def reporters
      Flowerbox.reporters
    end

    def initialize(results = [], options = {})
      @results, @options = results, options
    end

    def <<(other)
      other.results.each do |other_result|
        if existing_result = results.find { |result| result == other_result }
          existing_result << other_result
        else
          results << other_result
        end
      end
    end

    def exitstatus
      if results.any?(&:failure?)
        1
      elsif results.any?(&:pending?)
        2
      else
        0
      end
    end

    def print(data = {})
      reporters.each { |reporter| reporter.report(flattened_gathered_results, data) }
    end

    def total_tests
      results.length
    end

    def total_failures
      results.reject(&:success?).length
    end

    def print_progress
      @results.each do |result|
        reporters.each do |reporter|
          begin
            reporter.report_progress(result)
          rescue => e
            puts e.message
            puts e.backtrace.join("\n")
            raise e
          end
        end
      end
    end

    def gathered_results
      return @gathered_results if @gathered_results

      @gathered_results = []

      results.each do |result|
        if !(gathered_result = @gathered_results.find { |g| g.name == result.name })
          gathered_result = GatheredResult.new(result.name)

          @gathered_results << gathered_result
        end

        gathered_result << result
      end

      @gathered_results
    end

    def flattened_gathered_results
      gathered_results.collect(&:results).flatten
    end
  end
end

