module Flowerbox
  module TestEnvironment
    extend Flowerbox::CoreExt::Module

    class << self
      def for(env)
        require "flowerbox/test_environment/#{env}"

        find_constant(env).new
      end
    end
  end
end

