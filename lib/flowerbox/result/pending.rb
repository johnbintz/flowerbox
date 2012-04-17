module Flowerbox::Result
  class Pending < Base
    def pending?
      true
    end

    def failure?
      false
    end

    def failures; [] ; end
  end
end

