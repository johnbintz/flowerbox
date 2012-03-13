module Flowerbox::Result
  module Jasmine
    class Success < Flowerbox::Result::Base
      def success? ; true ; end
    end
  end
end

