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
      first_local_stack[%r{\(([^:]+\:\d+)}, 1]
    end

    def runner
      @data['runner']
    end

    def runners
      @runners ||= [ runner ]
    end

    def first_local_stack
      @data['stack'][1..-1].find do |line|
        !system_files.any? { |file| line[%r{\(#{file}}] }
      end || @data['stack'][1] || ''
    end
  end
end

