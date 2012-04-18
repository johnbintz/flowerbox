require 'flowerbox/reporter/base'

module Flowerbox::Reporter
  class StepWriter < Base
    def report_undefined(result)
      target = File.join(options[:target], result.step_type.downcase, result.original_name.strip.downcase.gsub(%r{[^\w]+}, '_')) + '.js'

      if result.test_environment.primarily_coffeescript?
        target << '.coffee'
      end

      if !File.file?(target)
        self.puts "Writing #{target}..."

        File.open(target, 'wb') { |fh| fh.print result.test_environment.obtain_test_definition_for(result) }
      end
    end
  end
end

