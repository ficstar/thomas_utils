module ThomasUtils
  class ObjectStream

    def initialize(&callback)
      @buffer = Queue.new
      @callback = callback
    end

    def <<(item)
      @buffer << item
    end

    def flush
      length = @buffer.size
      items = length.times.map { @buffer.pop }
      @callback.call(items)
    end
  end
end