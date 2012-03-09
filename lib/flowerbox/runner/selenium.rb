require 'selenium-webdriver'

module Flowerbox
  module Runner
    class Selenium < Base
      MAX_COUNT = 30

      def name
        raise StandardError.new("Override me")
      end

      def type
        :selenium
      end

      def run(sprockets, spec_files, options)
        super do
          begin
            selenium = ::Selenium::WebDriver.for(browser)

            selenium.navigate.to "http://localhost:#{server.port}/"

            @count = 0

            while @count < MAX_COUNT && !finished?
              @count += 1
              sleep 0.1
            end
          ensure
            selenium.quit if selenium
          end
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
    <script type="text/javascript">
      Flowerbox.environment = '#{browser}';

      var context = this;

      #{env}
    </script>
  </body>
</html>
HTML
      end

      def template_files
        sprockets.files.collect { |file| %{<script type="text/javascript" src="/__F__#{file}"></script>} }
      end

      def add_failures(data)
        super

        @count = 0
      end
    end
  end
end

