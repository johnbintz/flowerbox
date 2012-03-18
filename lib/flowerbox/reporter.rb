module Flowerbox
  module Reporter
    extend Flowerbox::CoreExt::Module

    require 'flowerbox/reporter/file_display'

    require 'flowerbox/reporter/base'
    require 'flowerbox/reporter/console_base'
    require 'flowerbox/reporter/verbose'
    require 'flowerbox/reporter/progress'
  end
end

