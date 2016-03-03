module ThomasUtils
  class Future < Observation
    DEFAULT_EXECUTOR = ::Concurrent::CachedThreadPool.new

    def initialize(options = {}, &block)
      executor = options.fetch(:executor) { DEFAULT_EXECUTOR }
      observable = Concurrent::Future.execute(executor: executor, &block)
      super(executor, observable)
    end

  end
end

