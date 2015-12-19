module ThomasUtils
  class KeyChild
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

class Symbol
  def child(name)
    ThomasUtils::KeyChild.new(self, name)
  end
end
