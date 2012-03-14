module Flowerbox
  module Result
    extend Flowerbox::CoreExt::Module

    module Cucumber
      extend Flowerbox::CoreExt::Module
    end

    module Jasmine
      extend Flowerbox::CoreExt::Module
    end

    autoload :Base, 'flowerbox/result/base'
    autoload :Exception, 'flowerbox/result/exception'
    autoload :Failure, 'flowerbox/result/failure'
    autoload :Pending, 'flowerbox/result/pending'
    autoload :FailureMessage, 'flowerbox/result/failure_message'
    autoload :FileInfo, 'flowerbox/result/file_info'

    class << self
      def for(test_env, type)
        require "flowerbox/result/#{test_env}/#{type}"

        test_group = find_constant(test_env)
        test_group.find_constant(type)
      end
    end
  end
end

