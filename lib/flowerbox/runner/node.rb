require 'tempfile'
require 'json'
require 'flowerbox/runner/base'

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
        File.directory?(File.join(Dir.pwd, 'node_modules/ws'))
      end

      def cleanup ; end

      def configure
        Flowerbox.notify %x{bash -c "mkdir -p node_modules && npm link jsdom && npm link ws"}
      end

      def run(sprockets, spec_files, options)
        super do
          begin
            file = File.join(Dir.pwd, ".node-tmp.#{Time.now.to_i}.js")
            File.open(file, 'wb') { |fh| fh.print template }

            system %{node #{file}}

            if $?.exitstatus == 0
              count = 20
              while !finished? && count > 0
                sleep 0.1

                count -= 1
              end
            end
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
    ws = require('ws')

// expand the sandbox a bit
var context = function() {};
for (method in global) { context[method] = global[method]; }

jsdom.env(
  "<html><head><title></title></head><body></body></html>", [], function(errors, window) {
  context.window = window;
  context.WebSocket = ws;

  var gotFlowerbox = false;

  console._log = console.log;

  var socket = new ws('ws://localhost:#{server.port + 1}/');
  socket.onopen = function() {
    var files = #{sprockets.files.to_json};

    var fileLoader = function() {
      if (files.length > 0) {
        var file = files.shift();

        socket.onmessage = function(data) {
          vm.runInNewContext(data.data, context, file);

          for (thing in window) {
            if (!context[thing]) { context[thing] = window[thing] }
          }

          if (!gotFlowerbox && context.Flowerbox) {
            context.Flowerbox.environment = 'node';
            context.Flowerbox.UNKNOWN = '#{Flowerbox::Result::FileInfo::UNKNOWN}';
            context.Flowerbox.socket = socket;

            gotFlowerbox = true;
          }

          fileLoader();
        };

        socket.send(JSON.stringify(['load', file]));
      } else {
        socket.onmessage = null;

        #{env}

        var waitForFinish;
        waitForFinish = function() {
          if (!context.Flowerbox.started || !context.Flowerbox.done) {
            process.nextTick(waitForFinish);
          } else {
            process.exit(0);
          }
        };
        waitForFinish();
      }
    };

    fileLoader();
  };
});
JS
      end
    end
  end
end

