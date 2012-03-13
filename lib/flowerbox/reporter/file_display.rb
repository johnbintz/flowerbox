module Flowerbox::Reporter
  module FileDisplay
    private
    def path_for(result)
      if result.line.gsub(%r{[^0-9]}, '').to_i == 0
        ''
      else
        result.translated_file_and_line.foreground(:cyan)
      end
    end
  end
end

