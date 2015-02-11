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