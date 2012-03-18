require 'forwardable'

module Flowerbox
  module Result
    class Base
      require 'flowerbox/result/file_info'
      include Flowerbox::Result::FileInfo

      extend Forwardable

      attr_reader :data

      def_delegators :data, :[]

      def type
        self.class.name.split("::").last.downcase.to_sym
      end

      def initialize(data)
        @data = data
      end

      def name
        data['name']
      end

      def message
        data['message']
      end

      def runners
        data['runners']
      end

      def file
        data['file']
      end

      def ==(other)
        name == other.name
      end

      def <=>(other)
        result = self.name.length <=> other.name.length

        if result == 0

        end

        result
      end

      def runners
        @runners ||= []
      end

      def success?
        false
      end

      def failure?
        !success?
      end

      def pending?
        false
      end

      def <<(other)
        runners
        @runners += other.runners
      end

      def test_environment
        Flowerbox.test_environment
      end
    end
  end
end

