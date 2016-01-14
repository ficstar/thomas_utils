module ThomasUtils
  class KeyComparer

    attr_reader :key

    def initialize(key, comparer)
      @key = key
      @comparer = comparer
    end

    def new_key(updated_key)
      KeyComparer.new(updated_key, comparer)
    end

    def quote(quote)
      quoted_key = if key.respond_to?(:quote)
                     key.quote(quote)
                   else
                     "#{quote}#{key}#{quote}"
                   end
      "#{quoted_key} #{comparer}"
    end

    def to_s
      "#{pretty_key} #{comparer}"
    end

    def ==(rhs)
      rhs.is_a?(KeyComparer) && key == rhs.key && comparer == rhs.comparer
    end
    alias :eql? :==

    def hash
      to_s.hash
    end

    protected

    attr_reader :comparer

    private

    def pretty_key
      key.is_a?(Array) ? "(#{key * ','})" : key
    end
  end
end
