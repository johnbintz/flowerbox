require 'jasmine-core'

module Flowerbox
  module TestEnvironment
    class Jasmine
      def name
        self.class.name.split("::").last
      end

      def inject_into(sprockets)
        @sprockets = sprockets

        @sprockets.append_path(::Jasmine::Core.path)

        @sprockets.add('jasmine.js')
        @sprockets.add('jasmine-html.js')
      end

      def start_for(runner)
        @sprockets.add("flowerbox/jasmine")
        @sprockets.add("flowerbox/jasmine/#{runner.type}")

        case runner.type
        when :node
          <<-JS
var jasmine = context.jasmine;

#{jasmine_reporters.join("\n")}
jasmine.getEnv().execute();
JS
        when :selenium
          <<-JS
jasmine.getEnv().addReporter(new jasmine.FlowerboxReporter());
jasmine.getEnv().execute();
JS
        end
      end

      def jasmine_reporters
        reporters.collect { |reporter| %{jasmine.getEnv().addReporter(new jasmine.#{reporter}());} }
      end

      def reporters
        @reporters ||= [ 'FlowerboxReporter' ]
      end
    end
  end
end

