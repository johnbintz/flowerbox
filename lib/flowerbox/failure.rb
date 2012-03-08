module Flowerbox
  class Failure < BaseResult
    def print_progress
      print "F".foreground(:red)
    end
  end
end

