require 'flowerbox/test_environment/base'

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
        super

        require 'flowerbox/tilt/feature_template'

        @sprockets.register_engine('.feature', Flowerbox::Tilt::FeatureTemplate)
      end

      def global_system_files
        %w{cucumber.js flowerbox/cucumber}
      end

      def runner_system_files
        [ "flowerbox/cucumber/#{@runner.type}" ]
      end

      def start
        super

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

        messages = []

        if result['hasDataTable']
          args << "table"
          messages << "table is a Cucumber AST data table"
        end

        if result['hasDocString']
          args << "string"
          messages << "string is a doc string"
        end

        args_string = args.join(', ')

        output = []

        if primarily_coffeescript?
          output << %{Flowerbox.#{result.step_type} /^#{matcher}$/, #{"(#{args_string}) " if !args_string.empty?}->}
          output += messages.collect { |msg| "  # #{msg}" }
          output << %{  @pending() # add your code here}
        else
          output << "Flowerbox.#{result.step_type}(/^#{matcher}$/, function(#{args_string}) {"
          output += messages.collect { |msg| "  // #{msg}" }
          output << %{  this.pending(); // add your code here}
          output << "});"
        end

        output.collect { |line| "#{line}\n" }.join
      end

      def primarily_coffeescript?
        return true if @step_language == :coffeescript

        coffee_count = @runner.spec_files.inject(0) { |s, n| s += 1 if n[%r{.coffee$}]; s }
        js_count = @runner.spec_files.inject(0) { |s, n| s += 1 if n[%r{.js$}]; s }

        coffee_count > js_count
      end

      def plant_source
        "skel/cucumber"
      end

      def plant_target
        "js-features"
      end
    end
  end
end

