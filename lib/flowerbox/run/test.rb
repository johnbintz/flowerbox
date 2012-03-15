module Flowerbox::Run
  class Test < Base
    def execute
      prep!

      result_set = Flowerbox::ResultSet.new

      time = 0
      realtime = Time.now.to_i

      runner_envs = Flowerbox.runner_environment.collect do |env|
        env.ensure_configured!

        result_set << env.run(sprockets, spec_files, options)

        time += env.time

        env
      end

      result_set.print(:time => time, :realtime => Time.now.to_i - realtime)

      runner_envs.each(&:cleanup)

      result_set.exitstatus
    end
  end
end
