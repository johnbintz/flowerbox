module Flowerbox::Run
  class Debug < Base
    def execute
      prep!

      env = Flowerbox.runner_environment.first
      env.setup(sprockets, spec_files, options)

      Flowerbox.reporters.replace([])

      puts "Flowerbox debug server running test prepared for #{env.console_name} on #{env.server.address}"

      env.server.start

      trap('INT') do
        env.server.stop
      end

      @restart = false

      trap('QUIT') do
        puts "Restarting Flowerbox server..."
        @restart = true
        env.server.stop
      end

      while env.server.alive?
        sleep 0.25
      end

      if @restart
        debug(dir, options)
      else
        puts "Flowerbox finished."
      end
    end

    def options
      @options.dup.merge(:debug => true)
    end
  end
end

