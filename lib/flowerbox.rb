require "flowerbox/version"
require 'flowerbox-delivery'
require 'rainbow'

module Flowerbox
  module CoreExt
    autoload :Module, 'flowerbox/core_ext/module'
  end

  autoload :Runner, 'flowerbox/runner'
  autoload :Task, 'flowerbox/task'

  module Run
    autoload :Base, 'flowerbox/run/base'
    autoload :Test, 'flowerbox/run/test'
    autoload :Debug, 'flowerbox/run/debug'
  end

  module Runner
    autoload :Node, 'flowerbox/runner/node'
    autoload :Selenium, 'flowerbox/runner/selenium'
    autoload :Firefox, 'flowerbox/runner/firefox'
    autoload :Chrome, 'flowerbox/runner/chrome'
    autoload :Base, 'flowerbox/runner/base'
  end

  autoload :TestEnvironment, 'flowerbox/test_environment'

  module TestEnvironment
    autoload :Base, 'flowerbox/test_environment/base'
    autoload :Jasmine, 'flowerbox/test_environment/jasmine'
    autoload :Cucumber, 'flowerbox/test_environment/cucumber'
  end

  autoload :Rack, 'flowerbox/rack'

  autoload :ResultSet, 'flowerbox/result_set'
  autoload :GatheredResult, 'flowerbox/gathered_result'
  autoload :Result, 'flowerbox/result'

  autoload :Reporter, 'flowerbox/reporter'

  class << self
    attr_writer :reporters
    attr_accessor :port

    def reset!
      @spec_patterns = nil
      @spec_files = nil
      @asset_paths = nil
      @reporters = nil
      @port = nil
    end

    def spec_patterns
      @spec_patterns ||= []
    end

    def asset_paths
      @asset_paths ||= []
    end

    def reporters
      @reporters ||= []
    end

    def additional_files
      @additional_files ||= []
    end

    def test_with(what)
      self.test_environment = Flowerbox::TestEnvironment.for(what)
    end

    def run_with(*whats)
      self.runner_environment = whats.flatten.collect { |what| Flowerbox::Runner.for(what.to_s) }
    end

    def report_with(*whats)
      self.reporters = whats.flatten.collect { |what| Flowerbox::Reporter.for(what.to_s) }
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

      if reporters.empty?
        reporters << Flowerbox::Reporter.for(:progress)
      end
    end

    def bare_coffeescript
      @bare_coffeescript ||= true
    end

    def debug(dir, options = {})
      Flowerbox::Run::Debug.execute(dir, options)
    end

    def run(dir, options = {})
      Flowerbox::Run::Test.execute(dir, options)
    end

    def browsers
      @browsers ||= {}
    end

    def cleanup!
      browsers.values.each do |browser|
        begin
          browser.close
        rescue Errno::ECONNREFUSED => e
          puts "Browser already closed."
        end
      end

      @browsers = {}
    end
  end
end

