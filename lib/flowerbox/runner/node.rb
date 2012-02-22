require 'tempfile'

module Flowerbox
  module Runner
    class Node
      def self.run(files)
        new(files).run
      end

      def initialize(files)
        @files = files
      end

      def run
        file = Tempfile.new("node")
        file.print template
        file.close

        system %{node #{file.path}}

        $?.exitstatus
      end

      def template
        <<-JS
var fs = require('fs');
var window = this;

#{template_files.join("\n")}
#{start_test_environment}
JS
      end

      def template_files
        @files.collect { |file| %{eval(fs.readFileSync('#{file}', 'utf-8'));} }
      end

      def start_test_environment
        Flowerbox.test_environment.start_for(:node)
      end
    end
  end
end

