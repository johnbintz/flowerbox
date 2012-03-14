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

    def self.empty_post(*args, &block)
      post(*args) do
        instance_eval(&block)

        ""
      end
    end

    empty_post '/results' do
      runner.finish!(data.flatten.first)
    end

    empty_post '/start_test' do
      runner.add_tests(data.flatten)
    end

    empty_post '/finish_test' do
      runner.add_results(data.flatten)
    end

    empty_post '/log' do
      runner.log(data.first)
    end

    empty_post '/ping' do
      runner.ping
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
  end
end

