require 'selenium-webdriver'

module Flowerbox
  module Runner
    class Selenium < Base
      attr_accessor :browser, :results

      def run(sprockets)
        super

        selenium = ::Selenium::WebDriver.for :firefox

        Rack.runner = self

        server.start

        selenium.navigate.to "http://localhost:#{server.port}/"

        1.upto(30) do
          if results
            break
          else
            sleep 1
          end
        end

        if results
          puts results

          exit (results.split('/').last.to_i == 0) ? 0 : 1
        else
          exit 1
        end
      ensure
        selenium.quit if selenium
      end

      def log(msg)
        puts msg
      end

      def template
        env = start_test_environment

        <<-HTML
<html>
  <head>
    <title>Flowerbox - Selenium Runner</title>
    <script type="text/javascript">
this.Flowerbox = {
  contact: function(url, message) {
    xhr = new XMLHttpRequest();
    xhr.open("POST", "/" + url);
    xhr.send(message);
  }
}

console._log = console.log;

console.log = function(msg) {
  console._log(msg);
  Flowerbox.contact("log", msg);
}
    </script>
    #{template_files.join("\n")}
  </head>
  <body>
    <h1>Flowerbox - Selenium Runner</h1>
    <script type="text/javascript">
      #{env}
    </script>
  </body>
</html>
HTML
      end

      def template_files
        sprockets.files.collect { |file| %{<script type="text/javascript" src="/__F__#{file}"></script>} }
      end
    end
  end
end

Flowerbox.runner_environment = Flowerbox::Runner::Selenium.new
