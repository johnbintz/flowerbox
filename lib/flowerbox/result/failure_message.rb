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
      file = first_local_stack

      if file['__F__']
        file[%r{^.*__F__/([^:]+:\d+)}, 1]
      else
        file[%r{\(([^:]+\:\d+)}, 1]
      end
    end

    def runner
      @data['runner']
    end

    def runners
      @runners ||= [ runner ]
    end

    def stack
      @data['stack'] || []
    end

    def filtered_stack
      filtered_stack = stack.reject { |line|
        Flowerbox.backtrace_filter.any? { |filter| line[filter] }
      }.collect { |line|
        line.gsub(%r{\.coffee:(\d+)}) do |_|
          ".coffee:~#{($1.to_i * 0.67 + 1).to_i}"
        end
      }

      filtered_stack.shift if exception?
      filtered_stack
    end

    def first_local_stack
      @first_local_stack ||= (stack[1..-1] || []).find do |line|
        !system_files.any? { |file| line[%r{\(#{file}}] }
      end || stack[1] || ''
    end

    def exception?
      (stack[0] || '')[%r{^.+Error: }]
    end
  end
end

