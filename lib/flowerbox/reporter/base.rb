module Flowerbox::Reporter
  class Base
    def post_report_data
      @post_report_data ||= {}
    end

    def report(gathered_results, data = {})
      gathered_results.each do |result|
        self.send("report_#{result.type}", result)
      end

      report_numeric_results(gathered_results, data)

      post_report_data.each do |type, data|
        puts
        self.send("post_report_#{type}", data)
      end
    end

    def post_report_success(data) ; end
    def post_report_skipped(data) ; end
    def post_report_pending(data) ; end

    def post_report_undefined(data)
      puts "Some steps were not defined. Define them using the following code:".foreground(:yellow)
      puts

      data.each do |code|
        puts code.foreground(:yellow)
      end
    end

    def post_report_failed(data) ; end

    protected
    def numeric_results_for(gathered_results)
      {
        :total => gathered_results.length,
        :failures => gathered_results.find_all(&:failure?).length,
        :pending => gathered_results.find_all(&:pending?).length
      }
    end
  end
end

