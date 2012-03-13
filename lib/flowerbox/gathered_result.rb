module Flowerbox
  class GatheredResult
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def <<(result)
      results << result
    end

    def results
      @results ||= []
    end

    def successes
      results.find_all(&:success?)
    end

    def failures
      results.reject(&:success?)
    end

    def success?
      @results.all?(&:success?)
    end
  end
end

