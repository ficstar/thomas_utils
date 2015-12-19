module ThomasUtils
  class KeyComparer

    attr_reader :key

    def initialize(key, comparer)
      @key = key
      @comparer = comparer
    end

    def new_key(updated_key)
      KeyComparer.new(updated_key, @comparer)
    end

    def to_s
      "#{pretty_key} #{@comparer}"
    end

    def ==(rhs)
      to_s == rhs.to_s
    end

    def eql?(rhs)
      self == rhs
    end

    def hash
      to_s.hash
    end

    private

    def pretty_key
      key.is_a?(Array) ? "(#{key * ','})" : key
    end
  end
end