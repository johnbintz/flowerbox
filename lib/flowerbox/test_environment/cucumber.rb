module Flowerbox
  module TestEnvironment
    class Cucumber
      def inject_into(sprockets)
        @sprockets = sprockets

        @sprockets.add('cucumber.js')
      end

      def start_for(runner)
        @sprockets.add("flowerbox/cucumber")
        @sprockets.add("flowerbox/cucumber/#{runner.type}")

        runner.spec_files.each { |file| @sprockets.add(file) }

        <<-JS
if (typeof context != 'undefined' && typeof jasmine == 'undefined') {
  jasmine = context.jasmine;
}

jasmine.getEnv().addReporter(new jasmine.FlowerboxReporter());
#{jasmine_reporters.join("\n")}
jasmine.getEnv().execute();
JS
      end

      def jasmine_reporters
        reporters.collect { |reporter| %{jasmine.getEnv().addReporter(new jasmine.#{reporter}());} }
      end
    end
  end
end


