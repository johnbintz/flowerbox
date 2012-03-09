require 'tempfile'
require 'flowerbox/delivery/server'
require 'json'

module Flowerbox
  module Runner
    class Node < Base
      def name
        "node.js"
      end

      def console_name
        "n".foreground(:white) +
        "o".foreground('#8cc84b') +
        "de".foreground(:white) +
        ".js".foreground('#8cc84b')
      end

      def type
        :node
      end

      def configured?
        File.directory?(File.join(Dir.pwd, 'node_modules/jsdom')) &&
        File.directory?(File.join(Dir.pwd, 'node_modules/XMLHttpRequest')) &&
        File.directory?(File.join(Dir.pwd, 'node_modules/cucumber'))
      end

      def configure
        system %{bash -c "mkdir -p node_modules && npm link jsdom && npm link xmlhttprequest && npm link cucumber"}
      end

      def run(sprockets, spec_files, options)
        super do
          begin
            file = File.join(Dir.pwd, ".node-tmp.#{Time.now.to_i}.js")
            File.open(file, 'wb') { |fh| fh.print template }

            system %{node #{file}}
          ensure
            File.unlink(file) if file
          end
        end
      end

      def template
        env = start_test_environment

        <<-JS
// whoa node
var fs = require('fs'),
    vm = require('vm'),
    http = require('http'),
    jsdom = require('jsdom'),
    xhr = require('xmlhttprequest')

// expand the sandbox a bit
var context = function() {};
for (method in global) { context[method] = global[method]; }

jsdom.env(
  "<html><head><title></title></head><body></body></html>", [], function(errors, window) {
  context.window = window;
  context.XMLHttpRequest = xhr.XMLHttpRequest;

  var gotFlowerbox = false;

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

          if (!gotFlowerbox && context.Flowerbox) {
            context.Flowerbox.baseUrl = "http://localhost:#{server.port}/";
            context.Flowerbox.environment = 'node';

            gotFlowerbox = true;
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

