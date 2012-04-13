module Flowerbox
  class Rack
    attr_accessor :runner, :sprockets

    def initialize(runner, sprockets)
      @runner, @sprockets = runner, sprockets
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      if sprockets_file = env['PATH_INFO'][%r{/__F__(.*)$}, 1]
        result = sprockets.call(env.merge('QUERY_STRING' => 'body=1', 'PATH_INFO' => sprockets_file))
        result[1]['Cache-Control'] = 'max-age: 0; must-revalidate; no-store'
        result[1].delete('ETag')

        result
      else
        begin
          template = runner.template

          [ 200, { 'Content-type' => 'text/html' }, [ template ] ]
        rescue => e
          $stderr.puts
          $stderr.puts e.message
          $stderr.puts e.backtrace.join("\n")
          $stderr.puts

          [ 500, {}, [] ]
        end
      end
    end
  end
end

