require 'capybara'
require 'capybara/dsl'
require 'sinatra'
require 'thread'

module Flowerbox
  module Runner
    class Selenium < Base
      include Capybara::DSL

      class Rack < Sinatra::Base
        class << self
          attr_accessor :runner
        end

        def runner
          self.class.runner
        end

        post '/results' do
          runner.results = request.body.string
        end

        post '/log' do
          runner.log(request.body.string)
        end

        get %r{^/__F__(/.*)$} do |file|
          File.read(file)
        end

        get '/' do
          runner.template
        end
      end

      attr_accessor :browser, :results

      def run(sprockets)
        super

        Capybara.register_driver :firefox do |app|
          Capybara::Selenium::Driver.new(app, :browser => :firefox)
        end

        Capybara.default_driver = :firefox

        Rack.runner = self
        Capybara.app = Rack

        visit '/'

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
