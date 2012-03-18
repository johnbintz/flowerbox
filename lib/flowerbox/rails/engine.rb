require 'rails/engine'

module Flowerbox
  module Rails
    class Engine < ::Rails::Engine
      rake_tasks do
        require 'flowerbox/task'

        Flowerbox::Task.create("flowerbox:spec", :dir => "spec/javascripts")
        Flowerbox::Task.create("flowerbox:integration", :dir => "js-features")
      end
    end
  end
end

