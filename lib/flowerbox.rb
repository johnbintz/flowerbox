require "flowerbox/version"

module Flowerbox
  module Runner
    autoload :Node, 'flowerbox/runner/node'
  end

  class << self
    def spec_patterns
      @spec_patterns ||= []
    end

    def asset_paths
      @asset_paths ||= []
    end

    def test_with(what)
      @test_with = what
    end

    def load_test_environment(sprockets)
      require "flowerbox/test_environment/#{@test_with}"

      Flowerbox.test_environment.inject_into(sprockets)
    end

    attr_accessor :test_environment, :bare_coffeescript

    def configure
      yield self
    end
  end
end

