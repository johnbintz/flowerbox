module Flowerbox
  module CoreExt
    module Module
      def find_constant(string)
        const_get(constants.find { |f| f.to_s.downcase == string.to_s.downcase.gsub('_', '') })
      end

      def for(env)
        find_constant(env).new
      end
    end
  end
end

