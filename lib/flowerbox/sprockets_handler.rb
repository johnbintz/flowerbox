require 'sprockets'
require 'sprockets/engines'
require 'forwardable'
require 'sprockets-vendor_gems'
require 'fileutils'

module Flowerbox
  class SprocketsHandler
    extend Forwardable

    attr_reader :files, :options

    def_delegators :environment, :append_path, :register_engine, :[], :call

    def self.gem_asset_paths
      @gem_asset_paths ||= Sprockets.find_gem_vendor_paths
    end

    def initialize(options)
      @options = options

      require 'flowerbox/unique_asset_list'

      @files = Flowerbox::UniqueAssetList.new(self)
    end

    def add(asset)
      assets_for(asset).each { |dependent_asset| @files.add(dependent_asset) }
    end

    def assets_for(asset)
      environment.find_asset(asset, :bundle => true).to_a
    end

    def expire_index!
      @environment.send(:expire_index!)
    end

    def environment
      return @environment if @environment

      @environment = Sprockets::Environment.new
      @environment.cache = Sprockets::Cache::FileStore.new(Flowerbox.cache_dir)

      self.class.gem_asset_paths.each { |path| append_path(path) }
      options[:asset_paths].each { |path| append_path(path) }

      @environment
    end

    def asset_for(*args)
      environment.find_asset(*args)
    end

    def logical_path_for(asset)
      asset_path = asset.pathname.to_s

      environment.paths.each do |path|
        if result = asset_path[%r{^#{path}/(.*)}, 1]
          return result
        end
      end

      raise StandardError.new("Could not find logical path for #{asset_path}")
    end
  end
end

