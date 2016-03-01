module Concurrent
  module ExecutorService
    def execute(*args, &block)
      post(*args, &block)
    end
  end
end
