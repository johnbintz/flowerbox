require "flowerbox/version"
require 'rainbow'
require 'forwardable'

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
  require 'flowerbox/configuration'

  if defined?(Rails::Engine)
    require 'flowerbox/rails/engine'
  end

  CACHE_DIR = 'tmp/sprockets'

  class << self
    def reset!
      @configuration = nil
    end

    def configuration
      @configuration ||= Flowerbox::Configuration.new
    end

    def path
      Pathname(File.expand_path('../..', __FILE__))
    end

    def configure(&block)
      configuration.configure(&block)
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

    def method_missing(method, *args)
      if configuration.respond_to?(method)
        configuration.send(method, *args)
      else
        super
      end
    end
  end
end

