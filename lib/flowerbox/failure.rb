module Flowerbox
  class Failure < BaseResult
    def pending?
      message == "pending"
    end

    def skipped?
      message == "skipped"
    end

    def undefined?
      message[%r{^Step not defined}]
    end

    def print_progress
      case message
      when "pending"
        print "P".foreground(:yellow)
      when "skipped"
        print "-".foreground(:cyan)
      else
        if undefined?
          print "U".foreground(:yellow)
        else
          print "F".foreground(:red)
        end
      end
    end
  end
end

