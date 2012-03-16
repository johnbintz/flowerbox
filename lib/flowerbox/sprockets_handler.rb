require 'sprockets'
require 'sprockets/engines'
require 'forwardable'
require 'sprockets-vendor_gems'

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

      @files = Flowerbox::UniqueAssetList.new
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
      @environment.cache = Sprockets::Cache::FileStore.new(".tmp")

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
  end
end

