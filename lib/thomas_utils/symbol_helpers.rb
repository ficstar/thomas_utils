module ThomasUtils
  module SymbolHelpers
    OPERATOR_MAP = {eq: '=', ge: '>=', gt: '>', le: '<=', lt: '<', ne: '!='}

    OPERATOR_MAP.each do |method, operator|
      define_method(method) { to_comparer(operator) }
    end

    def to_comparer(operator)
      ThomasUtils::KeyComparer.new(self, operator)
    end

    def index(index)
      ThomasUtils::KeyIndexer.new(self, index)
    end

    def child(name)
      ThomasUtils::KeyChild.new(self, name)
    end
    alias :>> :child
  end
end

class Symbol
  include ThomasUtils::SymbolHelpers
end

class Array
  include ThomasUtils::SymbolHelpers
end
