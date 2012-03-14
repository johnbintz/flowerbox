require 'guard'
require 'guard/guard'

module Guard
  class Flowerbox < ::Guard::Guard
    def initialize(watchers = [], options = {})
      @options = options
    end

    def start
      puts "Starting Guard::Flowerbox..."
    end

    def run_all
      ::Flowerbox.run(@options[:dir], @options)
    end

    def run_on_change(files = [])
      ::Flowerbox.run(@options[:dir], @options.merge(:files => files))
    end
  end
end

