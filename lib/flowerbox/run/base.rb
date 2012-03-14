module Flowerbox::Run
  class Base
    attr_reader :dir, :options

    def self.execute(dir, options)
      new(dir, options).execute
    end

    def initialize(dir, options)
      @dir, @options = dir, options
    end

    def execute
      raise StandardError.new("override in subclass")
    end

    def prep!
      Flowerbox.reset!

      load File.join(dir, 'spec_helper.rb')

      require 'coffee_script'
      require 'tilt/coffee'

      Tilt::CoffeeScriptTemplate.default_bare = Flowerbox.bare_coffeescript

      if runners = options[:runners] || options[:runner]
        Flowerbox.run_with(runners.split(','))
      end

      Flowerbox.test_environment.set_additional_options(options[:env_options])
    end

    def sprockets
      sprockets = Flowerbox::Delivery::SprocketsHandler.new(
        :asset_paths => [
          Flowerbox.path.join("lib/assets/javascripts"),
          Flowerbox.path.join("vendor/assets/javascripts"),
          @dir,
          Flowerbox.asset_paths
        ].flatten
      )

      sprockets.add('flowerbox')
      sprockets.add('json2')

      Flowerbox.test_environment.inject_into(sprockets)

      Flowerbox.additional_files.each { |file| sprockets.add(file) }

      sprockets
    end

    def spec_files
      return @spec_files if @spec_files

      @spec_files = []

      Flowerbox.spec_patterns.each do |pattern|
        Dir[File.join(dir, pattern)].each do |file|
          if !only || only.find { |match| file[%r{^#{match}}] }
            @spec_files << File.expand_path(file)
          end
        end
      end

      @spec_files
    end

    def only
      return @only if @only

      @only = options[:files] || []
      @only = nil if only.empty?
      @only
    end
  end
end

