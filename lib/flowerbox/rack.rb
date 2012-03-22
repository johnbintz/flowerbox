require 'sinatra'
require 'cgi'

module Flowerbox
  class Rack < Sinatra::Base
    class << self
      attr_accessor :runner, :sprockets
    end

    def sprockets
      self.class.sprockets
    end

    def runner
      self.class.runner
    end

    get %r{^/__F__/(.*)$} do |file|
      asset = sprockets.asset_for(file, :bundle => false)

      halt(404) if !asset

      content_type asset.content_type
      asset.body
    end

    get '/' do
      begin
        runner.template
      rescue Flowerbox::Runner::Base::RunnerDiedError => e
        e.message
      end
    end
  end
end

