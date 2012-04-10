require 'forwardable'

module Flowerbox
  class ReporterList
    include Enumerable
    extend Forwardable

    def_delegators :@reporters, :empty?

    def each(&block)
      @reporters.each(&block)
    end

    def initialize
      clear!
    end

    def clear!
      @reporters = []
    end

    def <<(reporter)
      @reporters << Flowerbox::Reporter.for(reporter)
    end

    def add(reporter, options)
      reporter_obj = Flowerbox::Reporter.for(reporter)
      reporter_obj.options = options
      @reporters << reporter_obj
    end

    def start(message)
      on_each_reporter(:start, message)
    end

    def log(message)
      on_each_reporter(:log, message)
    end

    private
    def on_each_reporter(method, message)
      @reporters.each { |reporter| reporter.send(method, message) }
    end
  end
end

