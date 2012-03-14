require "flowerbox/version"
require 'flowerbox-delivery'
require 'rainbow'

module Guard
  autoload :Flowerbox, 'guard/flowerbox'
end

module Flowerbox
  module CoreExt
    autoload :Module, 'flowerbox/core_ext/module'
  end

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

    def prep(dir, options = {})
      reset!

      load File.join(dir, 'spec_helper.rb')

      require 'coffee_script'
      require 'tilt/coffee'

      Tilt::CoffeeScriptTemplate.default_bare = Flowerbox.bare_coffeescript

      if runners = options[:runners] || options[:runner]
        Flowerbox.run_with(runners.split(','))
      end
    end

    def debug(dir, options = {})
      options[:debug] = true

      prep(dir, options)

      env = Flowerbox.runner_environment.first
      env.setup(build_sprockets_for(dir), spec_files_for(dir), options)

      Flowerbox.reporters.replace([])

      puts "Flowerbox debug server running test prepared for #{env.console_name} on #{env.server.address}"

      env.server.start

      trap('INT') do
        env.server.stop
      end

      @restart = false

      trap('QUIT') do
        puts "Restarting Flowerbox server..."
        @restart = true
        env.server.stop
      end

      while env.server.alive?
        sleep 0.25
      end

      if @restart
        debug(dir, options)
      else
        puts "Flowerbox finished."
      end
    end

    def run(dir, options = {})
      prep(dir, options)

      result_set = ResultSet.new

      time = 0
      realtime = Time.now.to_i

      runner_envs = Flowerbox.runner_environment.collect do |env|
        env.ensure_configured!

        result_set << env.run(build_sprockets_for(dir), spec_files_for(dir), options)

        time += env.time

        env
      end

      result_set.print(:time => time, :realtime => Time.now.to_i - realtime)

      runner_envs.each(&:cleanup)

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

      Flowerbox.additional_files.each { |file| sprockets.add(file) }

      sprockets
    end

    def spec_files_for(dir)
      return @spec_files if @spec_files

      @spec_files = []

      Flowerbox.spec_patterns.each do |pattern|
        Dir[File.join(dir, pattern)].each do |file|
          @spec_files << File.expand_path(file)
        end
      end

      @spec_files
    end
  end
end

