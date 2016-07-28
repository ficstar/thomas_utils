module ThomasUtils
  class ThreadContext < Hash
    def self.current
      Thread.current[:__tutils_thread_context] ||= ThreadContext.new(Thread.current)
    end

    def initialize(thread)
      @thread = thread
      super()
    end

    def push_state(attributes)
      if attributes.any?
        previous = attribute_slice(attributes)
        merge!(attributes)
        result = yield
        merge!(previous)
        result
      else
        yield
      end
    end

    def id
      id = @thread.object_id.to_s(16)
      "0x#{id}"
    end

    private

    def attribute_slice(attributes)
      attributes.inject({}) do |memo, (key, _)|
        memo.merge!(key => self[key])
      end
    end
  end
end
