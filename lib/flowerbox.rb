require "flowerbox/version"
require 'rainbow'

module Flowerbox
  require 'flowerbox/core_ext/module'

  require 'flowerbox/runner'

  require 'flowerbox/run/base'
  require 'flowerbox/run/test'
  require 'flowerbox/run/debug'

  require 'flowerbox/test_environment'
  require 'flowerbox/result'
  require 'flowerbox/result_set'
  require 'flowerbox/gathered_result'

  require 'flowerbox/reporter'

  if defined?(Rails::Engine)
    require 'flowerbox/rails/engine'
  end

  CACHE_DIR = 'tmp/sprockets'

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

    attr_accessor :test_environment, :runner_environment, :bare_coffeescript, :server

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

    def transplant(dir)
      Flowerbox::TestEnvironment.transplantable_environments.each do |env|
        break if env.transplant(dir)
      end
    end

    def cache_dir
      File.join(CACHE_DIR, Flowerbox.test_environment.name)
    end
  end
end

