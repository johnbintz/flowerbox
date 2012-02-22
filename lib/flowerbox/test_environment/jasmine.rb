require 'jasmine-core'

module Flowerbox
  module TestEnvironment
    class Jasmine
      def self.inject_into(sprockets)
        sprockets.append_path(::Jasmine::Core.path)

        sprockets.add('jasmine.js')
        sprockets.add('jasmine-html.js')
      end

      def self.start_for(runner)
        <<-JS
jasmine.NodeReporter = function() {}

jasmine.NodeReporter.prototype.reportSpecResults = function(spec) {
  console.log(spec.results().totalCount + '/' + spec.results().failedCount);

  if (spec.results().failedCount == 0) {
    process.exit(0);
  } else {
    process.exit(1);
  }
}

jasmine.NodeReporter.prototype.reportRunnerResults = function(runner) {
}

jasmine.getEnv().addReporter(new jasmine.NodeReporter());
jasmine.getEnv().execute();
JS
      end
    end
  end
end

Flowerbox.test_environment = Flowerbox::TestEnvironment::Jasmine

