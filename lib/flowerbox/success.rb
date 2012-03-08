module Flowerbox
  class Success < BaseResult
    def print_progress
      print ".".foreground(:green)
    end

    def success?
      true
    end
  end
end

