module ThomasUtils
  class FutureWrapper
    extend Forwardable

    def_delegator :@future, :join
    def_delegator :@future, :on_failure

    def initialize(future, &callback)
      @future = future
      @callback = callback
    end

    def get
      @result ||= @callback.call(@future.get)
    end

    def on_success
      @future.on_success { |result| yield @callback.call(result) }
    end
  end
end