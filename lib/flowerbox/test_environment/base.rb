require 'yaml'

module Flowerbox
  module TestEnvironment
    class Base
      def name
        self.class.name.split("::").last
      end

      def reporters
        @reporters ||= []
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
    end
  end
end

