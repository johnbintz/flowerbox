module Flowerbox
  class Failure < Result
    attr_reader :name, :message, :file

    def initialize(name, message, file)
      @name, @message, @file = name, message, file
    end

    def runners
      @runners ||= []
    end

    def ==(other)
      @name == other.name && @message == other.message
    end

    def to_s
      "#{message} [#{runners.join(',')}] (#{file})"
    end
  end
end

