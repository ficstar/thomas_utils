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
  end
end