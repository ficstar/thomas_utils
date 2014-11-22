class PeriodicFlusher
  @@streams = {}

  def self.<<(stream_desc)
    name = stream_desc[:name]
    unless @@streams[name]
      stream = stream_desc[:stream]
      @@streams[name] = stream
      Workers::PeriodicTimer.new(stream_desc[:timeout] || 1) { stream.flush }
    end
  end

  def self.[](name)
    @@streams[name]
  end
end