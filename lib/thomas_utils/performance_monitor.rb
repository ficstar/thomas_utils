module ThomasUtils
  class PerformanceMonitor

    def initialize(logger)
      @logger = logger
    end

    def monitor(sender, method, meta_data, item = nil, &block)
      item = Future.immediate(&block) unless item
      meta_data = {name: meta_data} unless meta_data.is_a?(Hash)

      item.on_complete do |_, error|
        performance_message = {
            sender: sender,
            method: method,
            started_at: item.initialized_at,
            completed_at: item.resolved_at,
            duration: item.resolved_at - item.initialized_at,
            error: error,
        }.merge(meta_data)
        @logger.write(performance_message)
      end
    end
  end
end
