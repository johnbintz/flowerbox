require 'jasmine-core'

module Flowerbox
  module TestEnvironment
    class Jasmine < Base
      def inject_into(sprockets)
        sprockets.append_path(::Jasmine::Core.path)

        super
      end

      def global_system_files
        %w{jasmine.js flowerbox/jasmine.js}
      end

      def runner_system_files
        [ "flowerbox/jasmine/#{@runner.type}.js" ]
      end

      def start
        super

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

