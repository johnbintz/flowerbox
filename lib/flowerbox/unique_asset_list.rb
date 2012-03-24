module Flowerbox
  class UniqueAssetList < ::Array
    attr_reader :sprockets

    def initialize(sprockets)
      super([])

      @sprockets = sprockets

      @included = {}
    end

    def add(files)
      [ files ].flatten.each do |file|
        self << file if !included?(file)
      end
    end

    def <<(file)
      super(file)

      @included[file.pathname.to_s] = true
    end

    def to_json
      collect { |file| sprockets.logical_path_for(file) }
    end

    def included?(file)
      @included[file.pathname.to_s]
    end
  end
end

