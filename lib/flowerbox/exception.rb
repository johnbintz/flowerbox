module Flowerbox
  class Exception < Result
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def print
      puts "[#{runners.join(',')}] #{name}"
      puts
    end
  end
end

