module Flowerbox
  module TestEnvironment
    class Base
      def name
        self.class.name.split("::").last
      end

      def reporters
        @reporters ||= []
      end
    end
  end
end

