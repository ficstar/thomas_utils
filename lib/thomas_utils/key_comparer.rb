module ThomasUtils
  class KeyComparer
    def initialize(key, comparer)
      @key = key
      @comparer = comparer
    end

    def to_s
      "#{@key} #{@comparer}"
    end
  end
end

class Symbol
  def eq
    ThomasUtils::KeyComparer.new(self, '=')
  end

  def ge
    ThomasUtils::KeyComparer.new(self, '>=')
  end

  def gt
    ThomasUtils::KeyComparer.new(self, '>')
  end

  def le
    ThomasUtils::KeyComparer.new(self, '<=')
  end

  def lt
    ThomasUtils::KeyComparer.new(self, '<')
  end

  def ne
    ThomasUtils::KeyComparer.new(self, '!=')
  end
end