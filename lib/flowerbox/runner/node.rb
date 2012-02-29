require 'tempfile'
require 'flowerbox/delivery/server'
require 'json'

module Flowerbox
  module Runner
    class Node < Base
      def run(sprockets)
        super

        file = File.join(Dir.pwd, ".node-tmp.#{Time.now.to_i}.js")
        File.open(file, 'wb') { |fh| fh.print template.tap { |o| puts o } }

        server.start

        system %{node #{file}}

        server.stop

        $?.exitstatus
      ensure
        File.unlink(file) if file
      end

      def template
        env = start_test_environment

        <<-JS
var fs = require('fs'),
    vm = require('vm'),
    http = require('http'),
    jsdom = require('jsdom');

// expand the sandbox a bit
var context = function() {};
for (method in global) { context[method] = global[method]; }

jsdom.env(
  "<html><head><title></title></head><body></body></html>", [], function(errors, window) {
  context.window = window;

  var files = #{sprockets.files.to_json};
  var fileRunner = function() {
    if (files.length > 0) {
      var file = files.shift();

      var options = {
        host: "localhost",
        port: #{server.port},
        path: "/__F__" + file,
        method: "GET"
      };

      var request = http.request(options, function(response) {
        var data = '';

        response.on('data', function(chunk) {
          data += chunk;
        });

        response.on('end', function() {
          vm.runInNewContext(data, context, file);

          for (thing in window) {
            if (!context[thing]) { context[thing] = window[thing] }
          }

          fileRunner();
        });
      });

      request.end();
    } else {
      #{env}
    }
  };
  fileRunner();
});
JS
      end
    end
  end
end

Flowerbox.runner_environment = Flowerbox::Runner::Node.new

