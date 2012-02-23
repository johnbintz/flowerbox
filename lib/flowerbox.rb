require "flowerbox/version"

module Flowerbox
  module Runner
    autoload :Node, 'flowerbox/runner/node'
    autoload :Selenium, 'flowerbox/runner/selenium'
    autoload :Base, 'flowerbox/runner/base'
  end

  class << self
    def spec_patterns
      @spec_patterns ||= []
    end

    def asset_paths
      @asset_paths ||= []
    end

    def test_with(what)
      require "flowerbox/test_environment/#{what}"
    end

    def run_with(what)
      require "flowerbox/runner/#{what}"
    end

    def path
      Pathname(File.expand_path('../..', __FILE__))
    end

    attr_accessor :test_environment, :runner_environment, :bare_coffeescript

    def configure
      yield self
    end
  end
end

