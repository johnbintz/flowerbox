module Flowerbox::Result
  module Cucumber
    class Undefined < Flowerbox::Result::Pending
      def step_type
        @data['step_type']
      end

      def original_name
        @data['original_name']
      end
    end
  end
end

