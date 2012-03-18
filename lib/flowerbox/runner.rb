module Flowerbox
  module Runner
    extend Flowerbox::CoreExt::Module

    def self.find_constant(string)
      require "flowerbox/runner/#{string}"

      super
    end
  end
end

