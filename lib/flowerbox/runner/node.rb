require 'tempfile'
require 'flowerbox/delivery/server'
require 'json'

module Flowerbox
  module Runner
    class Node < Base
      def run(sprockets)
        super

        file = Tempfile.new("node")
        file.print template
        file.close

        server.start

        system %{node #{file.path}}

        server.stop

        $?.exitstatus
      end

      def template
        env = start_test_environment

        <<-JS
var fs = require('fs'),
    vm = require('vm'),
    http = require('http');

// expand the sandbox a bit
var context = function() {};
context.window = true;
for (method in global) { context[method] = global[method]; }

var files = #{sprockets.files.to_json};
var fileRunner = function() {
  if (files.length > 0) {
    var file = files.shift();
    console.log(file);

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
        fileRunner();
      });
    });

    request.end();
  } else {
    #{env}
  }
};
fileRunner();
JS
      end
    end
  end
end

Flowerbox.runner_environment = Flowerbox::Runner::Node.new

