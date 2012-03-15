module Flowerbox::Result::FileInfo
  def translated_file
    @translated_file ||= filename
  end

  def file_translated?
    translated_file != filename
  end

  def filename
    file.to_s.split(":").first || 'unknown'
  end

  def line_number
    return @line_number if @line_number

    @line_number = file.to_s.split(":")[1]
    @line_number = "~#{@line_number}" if file_translated?
    @line_number ||= "0"
  end

  alias :line :line_number

  def translated_file_and_line
    "#{translated_file.gsub(%r{^/}, '')}:#{line_number}"
  end

  def system_files
    Flowerbox.test_environment.system_files
  end
end

