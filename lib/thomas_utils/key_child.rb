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

    def ==(rhs)
      rhs.is_a?(KeyChild) && key == rhs.key && child == rhs.child
    end
    alias :eql? :==

    def hash
      to_s.hash
    end
  end
end
