module ThomasUtils
  class KeyIndexer
    attr_reader :key

    def initialize(key, index)
      @key = key
      @index = index
    end

    def to_s
      "#{@key}['#{@index}']"
    end
  end
end

class Symbol
  def index(index)
    ThomasUtils::KeyIndexer.new(self, index)
  end
end
