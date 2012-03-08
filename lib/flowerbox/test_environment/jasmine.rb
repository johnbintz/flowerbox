require 'jasmine-core'

module Flowerbox
  module TestEnvironment
    class Jasmine < Base

      def inject_into(sprockets)
        @sprockets = sprockets

        @sprockets.append_path(::Jasmine::Core.path)

        @sprockets.add('jasmine.js')
        @sprockets.add('jasmine-html.js')
      end

      def start_for(runner)
        @sprockets.add("flowerbox/jasmine.js")
        @sprockets.add("flowerbox/jasmine/#{runner.type}.js")

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

      def reporters
        @reporters ||= []
      end
    end
  end
end

