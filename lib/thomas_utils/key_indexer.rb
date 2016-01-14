module ThomasUtils
  class KeyIndexer
    include SymbolHelpers

    attr_reader :key

    def initialize(key, index)
      @key = key
      @index = index
    end

    def to_s
      "#{@key}['#{@index}']"
    end

    def ==(rhs)
      rhs.is_a?(KeyIndexer) && key == rhs.key && index == rhs.index
    end
    alias :eql? :==

    def hash
      to_s.hash
    end

    protected

    attr_reader :index
  end
end
