module Flowerbox
  class UniqueAssetList < ::Array
    def add(files)
      [ files ].flatten.each { |file| self << file if !include?(file) }
    end

    def to_json
      collect(&:logical_path)
    end

    private
    def include?(file)
      any? { |other_file| other_file.pathname.to_s == file.pathname.to_s }
    end
  end
end

