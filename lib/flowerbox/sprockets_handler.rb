require 'sprockets'
require 'sprockets/engines'
require 'forwardable'
require 'sprockets-vendor_gems'
require 'fileutils'

module Flowerbox
  class SprocketsHandler
    extend Forwardable

    class LogicalPathNotFoundError < StandardError ; end

    attr_reader :files, :options

    def_delegators :environment, :append_path, :register_engine, :[], :call, :find_asset, :paths

    def self.gem_asset_paths
      @gem_asset_paths ||= Sprockets.find_gem_vendor_paths
    end

    def initialize(options)
      @options = options

      require 'flowerbox/unique_asset_list'

      @files = Flowerbox::UniqueAssetList.new(self)
    end

    def add(asset)
      assets_for(asset).each { |dependent_asset| files.add(dependent_asset) }
    end

    def assets_for(asset)
      find_asset(asset, :bundle => true).to_a
    end

    def environment
      return @environment if @environment

      @environment = Sprockets::Environment.new
      @environment.cache = cache

      default_asset_paths.each { |path| @environment.append_path(path) }

      @environment
    end

    def default_asset_paths
      self.class.gem_asset_paths + options[:asset_paths]
    end

    def cache
      Sprockets::Cache::FileStore.new(Flowerbox.cache_dir)
    end

    def logical_path_for(asset)
      asset_path = asset.pathname.to_s

      paths.each do |path|
        if result = asset_path[%r{^#{path}/(.*)}, 1]
          return result
        end
      end

      raise LogicalPathNotFoundError.new("Could not find logical path for #{asset_path}")
    end
  end
end

