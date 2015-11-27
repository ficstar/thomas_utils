module ThomasUtils
  class KeyComparer
    OPERATOR_MAP = {eq: '=', ge: '>=', gt: '>', le: '<=', lt: '<', ne: '!='}

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

    private

    def pretty_key
      key.is_a?(Array) ? "(#{key * ','})" : key
    end
  end
end

class Symbol
  ThomasUtils::KeyComparer::OPERATOR_MAP.each do |method, operator|
    define_method(method) { ThomasUtils::KeyComparer.new(self, operator) }
  end
end

class Array
  ThomasUtils::KeyComparer::OPERATOR_MAP.each do |method, operator|
    define_method(method) { ThomasUtils::KeyComparer.new(self, operator) }
  end
end
