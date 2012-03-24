require 'yaml'

module Flowerbox
  module TestEnvironment
    class Base
      attr_accessor :runner, :run

      def name
        self.class.name.split("::").last
      end

      def reporters
        @reporters ||= []
      end

      def self.transplantable?
        respond_to?(:transplant)
      end

      def set_additional_options(opts = nil)
        @options = {}

        if opts
          case opts
          when String
            @options = Hash[YAML.load(opts).collect { |k, v| [ k.to_sym, v ] }]
          when Hash
            @options = opts
          end

          @options[:tags] = [ @options[:tags] ].flatten(1) if @options[:tags]
        end
      end

      def inject_into(sprockets)
        @sprockets = sprockets

        system_files.each { |file| @sprockets.add(file) }
      end

      def system_files
        run.system_files + global_system_files + runner_system_files
      end

      def start
        runner.spec_files.each { |file| @sprockets.add(file) }
      end

      def actual_path_for(file)
        @sprockets.find_asset(file, :bundle => false).pathname.to_s
      end
    end
  end
end

