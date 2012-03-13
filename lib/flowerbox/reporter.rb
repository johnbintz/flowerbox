module Flowerbox
  module Reporter
    extend Flowerbox::CoreExt::Module

    autoload :Base, 'flowerbox/reporter/base'
    autoload :ConsoleBase, 'flowerbox/reporter/console_base'
    autoload :Verbose, 'flowerbox/reporter/verbose'
    autoload :Progress, 'flowerbox/reporter/progress'
    autoload :FileDisplay, 'flowerbox/reporter/file_display'
  end
end

