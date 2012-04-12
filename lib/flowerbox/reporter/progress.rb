require 'flowerbox/reporter/console_base'

module Flowerbox::Reporter
  class Progress < ConsoleBase
    def report_progress(result)
      print self.send("progress_#{result.type}")
      $stdout.flush
    end

    def progress_skipped
      "-".foreground(:blue)
    end

    def progress_success
      ".".foreground(:green)
    end

    def progress_failure
      "F".foreground(:red)
    end

    def progress_pending
      "P".foreground(:yellow)
    end

    def progress_undefined
      "U".foreground(:yellow)
    end
  end
end

