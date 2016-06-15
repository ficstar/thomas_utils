module ThomasUtils
  class InMemoryLogger
    extend Forwardable

    attr_reader :log

    def_delegator :@log, :<<, :write
    def_delegator :@log, :clear

    def initialize
      @log = Concurrent::Array.new
    end
  end
end
