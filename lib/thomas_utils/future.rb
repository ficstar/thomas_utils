module ThomasUtils
  class Future
    DEFAULT_EXECUTOR = ::Concurrent::CachedThreadPool.new

    def initialize(options = {})
      options[:executor] ||= DEFAULT_EXECUTOR

      @mutex = Mutex.new
      @future = ::Concurrent::Future.execute(executor: options[:executor]) do
        begin
          @result = yield
          @result = @result.get if @result.is_a?(FutureWrapper)
          @mutex.synchronize { @success_callback.call(@result) if @success_callback }
          @result
        rescue => e
          @error = e
          @mutex.synchronize { @failure_callback.call(e) if @failure_callback }
        end
      end
    end

    def get
      result = @future.value
      raise @error if @error
      result
    end

    def join
      get rescue nil
    end

    def on_success(&block)
      @mutex.synchronize { @success_callback = block }
      @success_callback.call(@result) if @future.fulfilled? && !@error
    end

    def on_failure(&block)
      @mutex.synchronize { @failure_callback = block }
      @failure_callback.call(@error) if @future.fulfilled? && @error
    end
  end
end