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

    def print
      puts name.join(' ')

      results.each do |result|
        puts "  #{result}"
      end

      puts
    end
  end
end

