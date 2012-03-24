module Flowerbox
  module Reporter
    extend Flowerbox::CoreExt::Module

    require 'flowerbox/reporter/file_display'

    def self.for(env)
      require "flowerbox/reporter/#{env}"

      find_constant(env).new
    end
  end
end

