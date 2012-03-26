require 'flowerbox/reporter/console_base'

module Flowerbox::Reporter
  class Verbose < ConsoleBase
    def initialize
      @name_stack = []
    end

    def indent(text, count)
      "  " * count + text
    end

    def report_progress(result)
      if result.name
        result.name.each_with_index do |name, index|
          if @name_stack[index] != name
            @name_stack = []

            if name != result.name.last
              message = name
            else
              message = self.send("progress_#{result.type}", result)
              if !(file_display = path_for(result)).empty?
                message << " # #{file_display}"
              end
            end

            puts indent(message, index)
          end
        end

        @name_stack = result.name.dup
      else
        puts result.data
      end
    end

    def progress_skipped(result)
      result.name.last.foreground(:blue)
    end

    def progress_success(result)
      result.name.last.foreground(:green)
    end

    def progress_failure(result)
      result.name.last.foreground(:red)
    end

    def progress_pending(result)
      "#{result.name.last} (Pending)".foreground(:yellow)
    end

    def progress_undefined(result)
      "#{result.name.last} (Undefined)".foreground(:yellow)
    end
  end
end

