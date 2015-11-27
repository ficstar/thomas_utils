module ThomasUtils
  class KeyComparer
    attr_reader :key

    def initialize(key, comparer)
      key = "(#{key * ','})" if key.is_a?(Array)
      @key = key
      @comparer = comparer
    end

    def new_key(updated_key)
      KeyComparer.new(updated_key, @comparer)
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

class Array
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
