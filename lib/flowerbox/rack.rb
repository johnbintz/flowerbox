require 'sinatra'

module Flowerbox
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
end

