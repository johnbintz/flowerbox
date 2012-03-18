module Flowerbox
  class UniqueAssetList < ::Array
    attr_reader :sprockets

    def initialize(sprockets)
      super([])

      @sprockets = sprockets
    end

    def add(files)
      [ files ].flatten.each { |file| self << file if !include?(file) }
    end

    def to_json
      collect { |file| sprockets.logical_path_for(file) }
    end

    private
    def include?(file)
      any? { |other_file| other_file.pathname.to_s == file.pathname.to_s }
    end
  end
end

