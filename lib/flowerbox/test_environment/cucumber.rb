module Flowerbox
  module TestEnvironment
    class Cucumber < Base
      def initialize
        @step_language = nil
      end
      
      def prefer_step_language(language)
        @step_language = language
      end

      def inject_into(sprockets)
        @sprockets = sprockets

        @sprockets.register_engine('.feature', Flowerbox::Delivery::Tilt::FeatureTemplate)

        @sprockets.add('cucumber.js')
      end

      def start_for(runner)
        @runner = runner

        @sprockets.add("flowerbox/cucumber")
        @sprockets.add("flowerbox/cucumber/#{runner.type}")

        @runner.spec_files.each { |file| @sprockets.add(file) }

        <<-JS
context.Cucumber = context.require('./cucumber');

options = {}
#{maybe_tags}

context.cucumber = context.Cucumber(context.Flowerbox.Cucumber.features(), context.Flowerbox.World(), options);
context.cucumber.attachListener(new context.Flowerbox.Cucumber.Reporter());
context.cucumber.start(function() {});
JS
      end

      def maybe_tags
        "options.tags = #{@options[:tags].to_json};" if @options[:tags]
      end

      def obtain_test_definition_for(result)
        matcher = result.original_name
        args = []

        matcher.gsub!(%r{"[^"]+"}) do |_, match|
          args << "arg#{args.length + 1}"
          '"([^"]+)"'
        end

        matcher.gsub!(%r{ \d+ }) do |_, match|
          args << "arg#{args.length + 1}"
          " (\d+) "
        end

        args_string = args.join(', ')

        if primarily_coffeescript?
          <<-COFFEE
Flowerbox.#{result.step_type} /^#{matcher}$/, #{"(#{args_string}) " if !args_string.empty?}->
  @pending() # add your code here
COFFEE
        else
          <<-JS
Flowerbox.#{result.step_type}(/^#{matcher}$/, function(#{args_string}) {
  this.pending(); // add your code here
});
JS
        end
      end

      def primarily_coffeescript?
        return true if @step_language == :coffeescript

        coffee_count = @runner.spec_files.inject(0) { |s, n| s += 1 if n[%r{.coffee$}]; s }
        js_count = @runner.spec_files.inject(0) { |s, n| s += 1 if n[%r{.js$}]; s }

        coffee_count > js_count
      end
    end
  end
end

module Flowerbox::Delivery::Tilt
  autoload :FeatureTemplate, 'flowerbox/delivery/tilt/feature_template'
end

