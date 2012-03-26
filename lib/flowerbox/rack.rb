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
        sprockets.call(env.merge('QUERY_STRING' => 'body=1', 'PATH_INFO' => sprockets_file))
      else
        [ 200, { 'Content-type' => 'text/html' }, [ runner.template ] ]
      end
    end
  end
end

