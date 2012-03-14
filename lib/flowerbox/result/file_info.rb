module Flowerbox::Result::FileInfo
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

    @line_number = file.to_s.split(":")[1]
    @line_number = "~#{@line_number}" if file_translated?
    @line_number
  end

  alias :line :line_number

  def translated_file_and_line
    "#{translated_file.gsub(%r{^/}, '')}:#{line_number}"
  end
end

