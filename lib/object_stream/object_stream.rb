class ObjectStream

  def initialize(proc)
    @buffer = Queue.new
    @proc = proc
  end

  def <<(item)
    @buffer << item
  end

  def flush
    length = @buffer.size
    items = length.times.map { @buffer.pop }
    @proc.call(items)
  end
end