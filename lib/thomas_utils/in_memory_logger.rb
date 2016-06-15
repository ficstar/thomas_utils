module ThomasUtils
  class InMemoryLogger
    attr_reader :log

    def initialize
      @log = Concurrent::Array.new
    end

    def write(entry)
      @log << entry
    end
  end
end
