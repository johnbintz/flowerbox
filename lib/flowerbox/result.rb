module Flowerbox
  module Result
    extend Flowerbox::CoreExt::Module

    module Cucumber
      extend Flowerbox::CoreExt::Module
    end

    module Jasmine
      extend Flowerbox::CoreExt::Module
    end

    require 'flowerbox/result/base'
    require 'flowerbox/result/exception'
    require 'flowerbox/result/failure'
    require 'flowerbox/result/pending'
    require 'flowerbox/result/failure_message'
    require 'flowerbox/result/file_info'

    class << self
      def for(test_env, type)
        require "flowerbox/result/#{test_env}/#{type}"

        test_group = find_constant(test_env)
        test_group.find_constant(type)
      end
    end
  end
end

