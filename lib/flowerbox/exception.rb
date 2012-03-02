module Flowerbox
  class Exception < Result
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def print
      puts message
      puts
    end
  end
end

