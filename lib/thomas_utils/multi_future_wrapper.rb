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
  end
end