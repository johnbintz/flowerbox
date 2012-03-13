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
jasmine.getEnv().execute();
JS
      end
    end
  end
end

