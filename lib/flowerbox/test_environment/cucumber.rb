module Flowerbox
  module TestEnvironment
    class Cucumber < Base
      def inject_into(sprockets)
        @sprockets = sprockets

        @sprockets.register_engine('.feature', Flowerbox::Delivery::Tilt::FeatureTemplate)

        @sprockets.add('cucumber.js')
      end

      def start_for(runner)
        @sprockets.add("flowerbox/cucumber")
        @sprockets.add("flowerbox/cucumber/#{runner.type}")

        runner.spec_files.each { |file| @sprockets.add(file) }

        <<-JS
context.Cucumber = context.require('./cucumber');

context.cucumber = context.Cucumber(context.Flowerbox.Cucumber.features(), context.Flowerbox.World());
context.cucumber.attachListener(new context.Flowerbox.Cucumber.Reporter());
context.cucumber.start(function() {});
JS
      end
    end
  end
end

module Flowerbox::Delivery::Tilt
  autoload :FeatureTemplate, 'flowerbox/delivery/tilt/feature_template'
end

