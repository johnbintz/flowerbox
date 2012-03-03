require "flowerbox/version"
require 'flowerbox-delivery'

module Flowerbox
  autoload :Runner, 'flowerbox/runner'

  module Runner
    autoload :Node, 'flowerbox/runner/node'
    autoload :Selenium, 'flowerbox/runner/selenium'
    autoload :Firefox, 'flowerbox/runner/firefox'
    autoload :Chrome, 'flowerbox/runner/chrome'
    autoload :Base, 'flowerbox/runner/base'
  end

  autoload :TestEnvironment, 'flowerbox/test_environment'

  module TestEnvironment
    autoload :Jasmine, 'flowerbox/test_environment/jasmine'
  end

  autoload :Rack, 'flowerbox/rack'

  autoload :ResultSet, 'flowerbox/result_set'
  autoload :GatheredResult, 'flowerbox/gathered_result'
  autoload :Result, 'flowerbox/result'
  autoload :Failure, 'flowerbox/failure'
  autoload :Exception, 'flowerbox/exception'

  class << self
    def spec_patterns
      @spec_patterns ||= []
    end

    def asset_paths
      @asset_paths ||= []
    end

    def test_with(what)
      self.test_environment = Flowerbox::TestEnvironment.for(what)
    end

    def run_with(*whats)
      self.runner_environment = whats.flatten.collect { |what| Flowerbox::Runner.for(what.to_s) }
    end

    def path
      Pathname(File.expand_path('../..', __FILE__))
    end

    attr_accessor :test_environment, :runner_environment, :bare_coffeescript

    def configure
      yield self

      if spec_patterns.empty?
        spec_patterns << "**/*_spec*"
        spec_patterns << "*/*_spec*"
      end
    end

    def bare_coffeescript
      @bare_coffeescript ||= true
    end

    def run(dir, options = {})
      load File.join(dir, 'spec_helper.rb')

      if options[:runners]
        Flowerbox.run_with(options[:runners].split(','))
      end

      require 'coffee_script'
      require 'tilt/coffee'

      Tilt::CoffeeScriptTemplate.default_bare = Flowerbox.bare_coffeescript

      result_set = ResultSet.new

      Flowerbox.runner_environment.each do |env|
        result_set << env.run(build_sprockets_for(dir), spec_files_for(dir))
      end

      result_set.print
      result_set.exitstatus
    end

    def build_sprockets_for(dir)
      sprockets = Flowerbox::Delivery::SprocketsHandler.new(
        :asset_paths => [
          Flowerbox.path.join("lib/assets/javascripts"),
          Flowerbox.path.join("vendor/assets/javascripts"),
          dir,
          Flowerbox.asset_paths
        ].flatten
      )

      sprockets.add('flowerbox')
      sprockets.add('json2')

      Flowerbox.test_environment.inject_into(sprockets)

      sprockets
    end

    def spec_files_for(dir)
      return @spec_files if @spec_files

      @spec_files = []

      Flowerbox.spec_patterns.each do |pattern|
        Dir[File.join(dir, pattern)].each do |file|
          @spec_files << file.gsub(dir + '/', '')
        end
      end

      @spec_files
    end
  end
end

