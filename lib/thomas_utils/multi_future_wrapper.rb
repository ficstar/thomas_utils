module ThomasUtils
  class MultiFutureWrapper
    def initialize(futures, &callback)
      @futures = futures
      @callback = callback
    end

    def join
      @futures.map(&:join)
    end

    def get
      @futures.map(&:get).map(&@callback)
    end

    def on_failure(&block)
      @futures.each { |future| future.on_failure(&block) }
    end

    def on_success
      @futures.each { |future| future.on_success { |result| yield @callback.call(result) } }
    end
  end
end