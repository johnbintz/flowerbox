require 'forwardable'

module Flowerbox
  module Reporter
    class Base
      extend Forwardable

      def_delegators :$stdout, :puts, :print

      attr_accessor :options

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

      def report_success(result); end
      def report_skipped(result) ; end
      def report_failure(result) ; end
      def report_pending(result) ; end
      def report_undefined(result) ; end

      def report_progress(result); end

      def post_report_success(data) ; end
      def post_report_skipped(data) ; end
      def post_report_pending(data) ; end
      def post_report_undefined(data)
        self.puts "Some steps were not defined. Define them using the following code:".foreground(:yellow)
        self.puts

        data.each do |code|
          self.puts code.foreground(:yellow)
        end
      end

      def post_report_failed(data) ; end
      def report_numeric_results(gathered_results, data = {}) ; end

      def start(message) ; end
      def log(message) ; end

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
end

