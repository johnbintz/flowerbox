module Flowerbox
  module Runner
    class << self
      def for(env)
        self.const_get(self.constants.find { |c| c.to_s.downcase.to_s == env.to_s }).new
      end
    end
  end
end

