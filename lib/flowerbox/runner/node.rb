require 'tempfile'

module Flowerbox
  module Runner
    class Node < Base
      def run(sprockets)
        super

        file = Tempfile.new("node")
        file.print template
        file.close

        system %{node #{file.path}}

        $?.exitstatus
      end

      def template
        env = start_test_environment

        <<-JS
var fs = require('fs'),
    vm = require('vm');

// expand the sandbox a bit
var context = function() {};
context.window = true;
for (method in global) { context[method] = global[method]; }

#{template_files.join("\n")}
#{env}
JS
      end

      def template_files
        sprockets.files.collect { |file| %{vm.runInNewContext(fs.readFileSync('#{file}', 'utf-8'), context, '#{file}');} }
      end
    end
  end
end

Flowerbox.runner_environment = Flowerbox::Runner::Node.new

