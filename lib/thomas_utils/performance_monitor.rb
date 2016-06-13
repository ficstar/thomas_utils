module ThomasUtils
  class PerformanceMonitor

    def initialize(logger)
      @logger = logger
    end

    def monitor(sender, method, monitor_name, item = nil, &block)
      item = Future.immediate(&block) unless item

      item.on_complete do |_, error|
        performance_message = {
            sender: sender,
            method: method,
            name: monitor_name,
            started_at: item.initialized_at,
            completed_at: item.resolved_at,
            duration: item.resolved_at - item.initialized_at,
            error: error,
        }
        @logger.write(performance_message)
      end
    end
  end
end
