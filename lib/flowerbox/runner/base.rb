module Flowerbox
  module Runner
    class Base
      attr_reader :sprockets

      def run(sprockets)
        @sprockets = sprockets
      end

      def type
        self.class.name.to_s.split('::').last.downcase.to_sym
      end

      def start_test_environment
        Flowerbox.test_environment.start_for(type)
      end
    end
  end
end

