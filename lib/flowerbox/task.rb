module Flowerbox
  class Task
    include Rake::DSL if defined?(Rake::DSL)

    def self.create(*args)
      new(*args).add
    end

    attr_reader :name, :options

    def initialize(name = "flowerbox", options = nil)
      @name = name
      @options = options || {}

      @options = { :dir => 'spec/javascripts' }.merge(@options)
    end

    def add
      desc "Run Flowerbox for the tests in #{options[:dir]}"
      task(name) do
        raise StandardError.new("Flowerbox tests failed") if Flowerbox.run(@options[:dir], @options) != 0
        Flowerbox.cleanup!
      end
    end
  end
end

