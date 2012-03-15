require 'selenium-webdriver'

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
          browser.navigate.to "http://localhost:#{server.port}/"

          ensure_alive
        end
      end

      def log(msg)
        puts msg
      end

      def template
        env = start_test_environment

        <<-HTML
<html>
  <head>
    <title>Flowerbox - #{Flowerbox.test_environment.name} Runner</title>
    <script type="text/javascript">
console._log = console.log;

console.log = function(msg) {
  console._log(msg);
  Flowerbox.contact("log", msg);
}
    </script>
    #{template_files.join("\n")}
  </head>
  <body>
    <h1>Flowerbox - #{Flowerbox.test_environment.name} Runner</h1>
    <pre id="queue"></pre>
    <script type="text/javascript">
      Flowerbox.environment = '#{name}';
      Flowerbox.onQueueStateChange = function(msg) {
        //document.getElementById('queue').innerHTML = document.getElementById('queue').innerHTML + "\\n" + msg;
      };

      var context = this;

      window.addEventListener('DOMContentLoaded', function() {
        #{env}
        Flowerbox.startQueueRunner()
      }, false);
    </script>
  </body>
</html>
HTML
      end

      def template_files
        sprockets.files.collect { |file| %{<script type="text/javascript" src="/__F__/#{file.logical_path}"></script>} }
      end
    end
  end
end

