module Flowerbox::Result
  class Failure < Flowerbox::Result::Base
    def failures
      @failures ||= @data['failures'].collect { |fail| FailureMessage.new(fail) }
    end

    def <<(other)
      super

      other.failures.each do |failure|
        if existing_failure = failures.find { |f| f.message == failure.message }
          existing_failure.runners << failure.runner
        else
          failures << failure
        end
      end
    end
  end
end

