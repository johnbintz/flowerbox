module Flowerbox::Result::FileInfo
  UNKNOWN = '__unknown__'

  def translated_file
    return @translated_file if @translated_file

    if filename == UNKNOWN
      @translated_file = UNKNOWN
    else
      @translated_file = Flowerbox.test_environment.actual_path_for(filename)
    end

    @translated_file
  end

  def file_translated?
    translated_file[%r{\.coffee$}]
  end

  def filename
    file.to_s.split(":").first || UNKNOWN
  end

  def line_number
    return @line_number if @line_number

    @line_number = file.to_s.split(":")[1]
    @line_number = "~#{(@line_number.to_i * 0.67).to_i}" if file_translated?
    @line_number ||= "0"
  end

  alias :line :line_number

  def translated_file_and_line
    "#{translated_file.gsub(%r{^#{Dir.pwd}/}, '')}:#{line_number}"
  end

  def system_files
    Flowerbox.test_environment.system_files
  end
end

