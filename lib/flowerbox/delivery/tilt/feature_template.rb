require 'tilt'

module Flowerbox::Delivery::Tilt
  class FeatureTemplate < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def prepare; end

    def evaluate(scope, locals, &block)
      <<-JS
Flowerbox.Cucumber.Features = Flowerbox.Cucumber.Features || [];

Flowerbox.Cucumber.Features.push("#{escaped_data}");
JS
    end

    def escaped_data
      data.gsub("\n", "\\n").gsub('"', '\\"')
    end
  end
end

