module ThomasUtils
  class Future
    def initialize
      @future = ::Concurrent::Future.execute do
        begin
          @result = yield
          @success_callback.call(@result) if @success_callback
          @result
        rescue => e
          @error = e
          @failure_callback.call(e) if @failure_callback
        end
      end
    end

    def get
      result = @future.value
      raise @error if @error
      result
    end

    def on_success(&block)
      if @future.fulfilled?
        block.call(@result) unless @error
      else
        @success_callback = block
      end
    end

    def on_failure(&block)
      if @future.fulfilled?
        block.call(@error) if @error
      else
        @failure_callback = block
      end
    end
  end
end