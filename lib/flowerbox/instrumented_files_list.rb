require 'forwardable'

module Flowerbox
  class InstrumentedFilesList
    extend Forwardable

    def_delegators :@files_list, :empty?

    def initialize
      @files_list = []
    end

    def <<(pattern)
      @files_list << pattern
    end

    def include?(filename)
      @files_list.any? { |pattern| filename[pattern] }
    end
  end
end

