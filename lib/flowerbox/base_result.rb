module Flowerbox
  class BaseResult < Result
    attr_reader :name, :message, :file

    def initialize(name, message, file = nil)
      @name, @message, @file = name, message, file
    end

    def ==(other)
      @name == other.name && @message == other.message
    end

    def to_s
      "#{message} [#{runners.join(',')}] (#{translated_file}:#{line_number})"
    end
  end
end

