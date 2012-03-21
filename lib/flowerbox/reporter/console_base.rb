module Flowerbox::Reporter
  class ConsoleBase < Base
    include FileDisplay

    def report_success(result) ; end
    def report_skipped(result) ; end

    def report_pending(result)
      puts
      puts result.name.join(" - ").foreground(:yellow)
      puts "  Pending (finish defining the test)".foreground(:yellow) + ' ' + path_for(result)
    end

    def report_undefined(result)
      (post_report_data[:undefined] ||= []) << result.test_environment.obtain_test_definition_for(result)
    end

    def report_failure(result)
      puts
      puts result.name.join(" - ").foreground(:red)
      result.failures.each do |failure|
        puts "  " + failure.message.foreground(:red) + " [" + failure.runners.join(',') + "] " + path_for(failure)
        puts failure.filtered_stack.join("\n").foreground(:red) if failure.exception?
      end
    end

    def report_numeric_results(gathered_results, data = {})
      results = numeric_results_for(gathered_results)

      output = "#{results[:total]} total, #{results[:failures]} failed, #{results[:pending]} pending, #{data[:time].to_f / 1000} (#{data[:realtime]}.0) secs."
      color = :green

      color = :yellow if results[:pending] > 0
      color = :red if results[:failures] > 0

      puts
      puts output.foreground(color)
      puts
    end
  end
end

