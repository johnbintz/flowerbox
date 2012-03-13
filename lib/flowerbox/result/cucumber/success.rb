module Flowerbox::Result
  module Cucumber
    class Success < Flowerbox::Result::Base
      def success?
        true
      end
    end
  end
end

