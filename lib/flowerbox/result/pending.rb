module Flowerbox::Result
  class Pending < Base
    def pending?
      true
    end

    def failure?
      false
    end
  end
end

