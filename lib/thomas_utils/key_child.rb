module ThomasUtils
  class KeyChild
    include SymbolHelpers

    attr_reader :key, :child

    def initialize(key, child)
      @key = key
      @child = child
    end

    def quote(quote)
      "#{quote}#{key}#{quote}.#{quote}#{child}#{quote}"
    end

    def to_s
      "#{@key}.#{@child}"
    end
  end
end
