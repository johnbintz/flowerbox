module Flowerbox
  module TestEnvironment
    extend Flowerbox::CoreExt::Module

    def self.for(env)
      require "flowerbox/test_environment/#{env}"

      find_constant(env).new
    end

    def self.transplantable_environments
      Dir[File.expand_path('../test_environment/*.rb', __FILE__)].each do |file|
        require file
      end

      constants.collect { |k| const_get(k) }.find_all(&:transplantable?)
    end
  end
end

