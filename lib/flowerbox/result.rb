module Flowerbox
  class Result
    def <=>(other)
      result = self.name.length <=> other.name.length

      if result == 0

      end

      result
    end

    def runners
      @runners ||= []
    end

    def translated_file
      @translated_file ||= if actual_file_base = filename[%r{\.tmp/sprockets(.*)}, 1]
        Dir[actual_file_base + "*"].first
      else
        filename
      end
    end

    def file_translated?
      translated_file != filename
    end

    def filename
      file.to_s.split(":").first
    end

    def line_number
      return @line_number if @line_number

      @line_number = file.to_s.split(":").last
      @line_number = "~#{@line_number}" if file_translated?
      @line_number
    end

    def success?
      false
    end
  end
end

