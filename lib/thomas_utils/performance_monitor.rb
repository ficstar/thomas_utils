module ThomasUtils
  class PerformanceMonitor

    def initialize(logger)
      @logger = logger
    end

    def monitor(sender, method, monitor_name, item = nil, &block)
      item = Future.immediate(&block) unless item

      item.on_timed do |started_at, completed_at, duration|
        performance_message = {
            sender: sender,
            method: method,
            name: monitor_name,
            started_at: started_at,
            completed_at: completed_at,
            duration: duration,
        }
        @logger.write(performance_message)
      end
    end
  end
end
