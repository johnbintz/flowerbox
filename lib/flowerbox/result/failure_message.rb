module Flowerbox::Result
  class FailureMessage
    include Flowerbox::Result::FileInfo

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def message
      @data['message']
    end

    def file
      first_local_stack[%r{__F__/(.*)$}, 1]
    end

    def runner
      @data['runner']
    end

    def runners
      @runners ||= [ runner ]
    end

    def first_local_stack
      @data['stack'].find { |line| line['__F__'] } || @data['stack'][1]
    end
  end
end

