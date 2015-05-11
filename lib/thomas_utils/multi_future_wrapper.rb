module ThomasUtils
  class MultiFutureWrapper
    def initialize(futures, leader = nil, &callback)
      @futures = futures
      @leader = leader
      @callback = callback
    end

    def join
      @futures.map(&:join)
    end

    def get
      @futures.map(&:get).map(&@callback)
    end

    def on_failure(&block)
      if @leader
        @leader.on_failure(&block)
      else
        @futures.each { |future| future.on_failure(&block) }
      end
    end

    def on_success
      @futures.each { |future| future.on_success { |result| yield @callback.call(result) } }
    end
  end
end