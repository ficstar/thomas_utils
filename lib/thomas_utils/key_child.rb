module ThomasUtils
  class KeyChild
    include SymbolHelpers

    attr_reader :key, :child

    def initialize(key, child)
      @key = key
      @child = child
    end

    def new_key(key)
      KeyChild.new(key, child)
    end

    def quote(quote)
      quoted_key = if key.respond_to?(:quote)
                     key.quote(quote)
                   else
                     "#{quote}#{key}#{quote}"
                   end
      "#{quoted_key}.#{quote}#{child}#{quote}"
    end

    def to_s
      "#{@key}.#{@child}"
    end
  end
end
