module Flowerbox
  class ResultSet
    attr_reader :results, :options

    def self.from_failures(failures, options)
      results = failures.collect do |result_data|
        if name = result_data.first['splitName']
          result_data.collect do |failure|
            Failure.new(name, failure['message'], failure['trace']['stack'].first)
          end
        else
          Exception.new(result_data['trace']['stack'])
        end
      end.flatten

      results.each { |result| result.runners << options[:runner] }

      new(results, options)
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

