require 'sinatra'
require 'json'
require 'cgi'

module Flowerbox
  class Rack < Sinatra::Base
    class << self
      attr_accessor :runner, :sprockets
    end

    def runner
      self.class.runner
    end

    def sprockets
      self.class.sprockets
    end

    def data
      JSON.parse(request.body.string)
    end

    def self.command(*args, &block)
      url, args = args
      url = "/#{url}"

      post(url, *args) do
        instance_eval(&block)

        ""
      end
    end

    command :results do
      runner.finish!(data.flatten.first)
    end

    command :start_test do
      runner.add_tests(data.flatten)
    end

    command :finish_test do
      runner.add_results(data.flatten)
    end

    command :log do
      runner.log(data.first)
    end

    command :ping do
      runner.ping
    end

    command :pause_timer do
      runner.pause_timer
    end

    command :unpause_timer do
      runner.unpause_timer
    end

    command :starting do
      runner.did_start!
    end

    get %r{^/__F__/(.*)$} do |file|
      asset = sprockets.asset_for(file, :bundle => false)

      content_type asset.content_type
      asset.body
    end

    get '/' do
      sprockets.expire_index!

      runner.template
    end

    class << self
      private
      def setup_protetion(builder)
      end
    end
  end
end

