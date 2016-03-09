module ThomasUtils
  class Future < Observation
    DEFAULT_EXECUTOR = ::Concurrent::CachedThreadPool.new
    IMMEDIATE_EXECUTOR = ::Concurrent::ImmediateExecutor.new

    def self.value(value)
      Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.value(value))
    end

    def self.immediate(&block)
      none.then(&block)
    end

    def self.none
      Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.none)
    end

    def self.error(error)
      Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.error(error))
    end

    def initialize(options = {}, &block)
      executor = options.fetch(:executor) { DEFAULT_EXECUTOR }
      observable = Concurrent::Future.execute(executor: executor, &block)
      super(executor, observable)
    end

  end
end

