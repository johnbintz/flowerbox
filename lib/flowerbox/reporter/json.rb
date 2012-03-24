require 'flowerbox/reporter/base'
require 'json'

module Flowerbox::Reporter
  class JSON < Base
    def output
      @output ||= []
    end

    def log(message)
      @output << [ :log, message ]
    end

    def report_numeric_results(gathered_results, data = {})
      output << [ :results, numeric_results_for(gathered_results) ]

      self.puts ::JSON.dump(output)
    end
  end
end

