module ThomasUtils
  class KeyChild
    include SymbolHelpers

    attr_reader :key, :child

    def initialize(key, child)
      @key = key
      @child = child
    end

    def to_s
      "#{@key}.#{@child}"
    end
  end
end
