require 'flowerbox/reporter_list'

module Flowerbox
  class Configuration
    attr_writer :reporters, :backtrace_filter
    attr_accessor :port

    attr_accessor :test_environment, :runner_environment, :bare_coffeescript

    def spec_patterns
      @spec_patterns ||= []
    end

    def asset_paths
      @asset_paths ||= []
    end

    def reporters
      @reporters ||= Flowerbox::ReporterList.new
    end

    def additional_files
      @additional_files ||= []
    end

    def backtrace_filter
      @backtrace_filter ||= []
    end

    def test_with(what)
      self.test_environment = Flowerbox::TestEnvironment.for(what)
    end

    def run_with(*whats)
      self.runner_environment = whats.flatten.collect { |what| Flowerbox::Runner.for(what.to_s) }
    end

    def report_with(*whats)
      self.reporters.clear!
      whats.each { |what| self.reporters << what }
    end

    def configure
      yield self

      if spec_patterns.empty?
        spec_patterns << "**/*_spec*"
        spec_patterns << "*/*_spec*"
      end

      if reporters.empty?
        reporters << Flowerbox::Reporter.for(:progress)
      end
    end
  end
end

