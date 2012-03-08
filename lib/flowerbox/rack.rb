require 'sinatra'
require 'json'

module Flowerbox
  class Rack < Sinatra::Base
    class << self
      attr_accessor :runner
    end

    def runner
      self.class.runner
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
      p "made it"

      p data

      runner.finish!(data.flatten.first)
    end

    empty_post '/start_test' do
      runner.add_tests(data.flatten)
    end

    empty_post '/finish_test' do
      runner.add_results(data.flatten[1..-1])
    end

    empty_post '/log' do
      runner.log(data.first)
    end

    get %r{^/__F__(/.*)$} do |file|
      File.read(file)
    end

    get '/' do
      runner.template
    end
  end
end

