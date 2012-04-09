require 'selenium-webdriver'
require 'flowerbox/runner/base'

module Flowerbox
  module Runner
    class Selenium < Base
      def name
        raise StandardError.new("Override me")
      end

      def type
        :selenium
      end

      def cleanup
      end

      def browser
        raise StandardError.new("Define a browser")
      end

      def run(sprockets, spec_files, options)
        super do
          navigate = Proc.new { browser.navigate.to "http://localhost:#{server.port}/" }

          begin
            navigate.call
          rescue ::Selenium::WebDriver::Error::UnknownError => e
            puts "Browser communication error, reopening all browsers...".foreground(:yellow)
            Flowerbox.cleanup!

            navigate.call
          end

          ensure_alive
        end
      end

      def log(msg)
        puts msg
      end

      def page_title
        "Flowerbox - #{Flowerbox.test_environment.name} Runner"
      end

      def template
        env = start_test_environment

        <<-HTML
<html>
  <head>
    <title>#{page_title}</title>
  </head>
  <body>
    <h1>#{page_title}</h1>
    <pre id="queue"></pre>
    <script type="text/javascript">
console._log = console.log;

console.log = function(msg) {
  console._log(msg);
  Flowerbox.contact("log", msg);
}
    </script>
    #{template_files.join("\n")}
    <script type="text/javascript">
      Flowerbox.environment = '#{name}';
      Flowerbox.UNKNOWN = '#{Flowerbox::Result::FileInfo::UNKNOWN}';

      var context = this;

      window.addEventListener('DOMContentLoaded', function() {
        Flowerbox.socket = new WebSocket('ws://localhost:#{server.port + 1}/');
        Flowerbox.socket.onopen = function() {
          #{env}
        };
      }, false);
    </script>
  </body>
</html>
HTML
      end

      def template_files
        sprockets.files.collect { |file| %{<script type="text/javascript" src="/__F__/#{sprockets.logical_path_for(file)}"></script>} }
      end
    end
  end
end

