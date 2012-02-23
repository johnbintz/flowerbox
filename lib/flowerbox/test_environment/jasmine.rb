require 'jasmine-core'

module Flowerbox
  module TestEnvironment
    class Jasmine
      def inject_into(sprockets)
        @sprockets = sprockets

        @sprockets.append_path(::Jasmine::Core.path)

        @sprockets.add('jasmine.js')
        @sprockets.add('jasmine-html.js')
      end

      def start_for(runner)
        @sprockets.add("flowerbox/jasmine/#{runner}")

        case runner
        when :node
          <<-JS
var jasmine = context.jasmine;

#{jasmine_reporters.join("\n")}
jasmine.getEnv().execute();
JS
        when :selenium
          <<-JS
jasmine.getEnv().addReporter(new jasmine.TrivialReporter());
jasmine.getEnv().addReporter(new jasmine.SimpleSeleniumReporter());
jasmine.getEnv().execute();
JS
        end
      end

      def jasmine_reporters
        reporters.collect { |reporter| %{jasmine.getEnv().addReporter(new jasmine.#{reporter}());} }
      end

      def reporters
        @reporters ||= []
      end
    end
  end
end

Flowerbox.test_environment = Flowerbox::TestEnvironment::Jasmine.new

