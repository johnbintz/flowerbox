require 'sprockets'
require 'sprockets/engines'
require 'forwardable'
require 'sprockets-vendor_gems'
require 'fileutils'

module Flowerbox
  class SprocketsHandler
    extend Forwardable

    attr_reader :files, :options

    def_delegators :environment, :append_path, :register_engine, :[]

    def self.gem_asset_paths
      @gem_asset_paths ||= Sprockets.find_gem_vendor_paths
    end

    def initialize(options)
      @options = options

      require 'flowerbox/unique_asset_list'

      @files = Flowerbox::UniqueAssetList.new(self)
    end

    def add(asset)
      paths_for(asset).each { |path| add_paths_for_compiled_asset(path) }
    end

    def paths_for(asset)
      environment.find_asset(asset).to_a.collect(&:pathname)
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

    def add_paths_for_compiled_asset(path)
      asset_for(path, :bundle => false).to_a.each { |file_path| @files.add(file_path) }
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

