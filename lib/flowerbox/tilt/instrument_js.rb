require 'tilt'

module Flowerbox
  module Tilt
    class InstrumentJS < ::Tilt::Template
      def prepare ; end

      def evaluate(scope, locals, &block)
        if Flowerbox.instrument_files.include?(file)
          block_comment = false

          lines = data.lines.to_a

          output = [
            'if (typeof __$instrument == "undefined") { __$instrument = {} }',
            "__$instrument['#{file}'] = [];",
            "__$instrument['#{file}'][#{lines.length - 1}] = 0;"
          ]

          prior_comma_end = comma_end = false

          lines.each_with_index do |line, index|
            line.rstrip!

            instrument = "__$instrument['#{file}'][#{index}] = 1;"

            if line[%r{; *$}]
              line = line + instrument
            end

            output << line
          end

          output.join("\n")
        else
          data
        end
      end
    end
  end
end

