module ThomasUtils
  class PerformanceMonitor

    def initialize(logger)
      @logger = logger
    end

    def monitor(sender, method, meta_data, item = nil, &block)
      item = Future.immediate(&block) unless item
      meta_data = {name: meta_data} unless meta_data.is_a?(Hash)

      item.on_timed do |initialized_at, resolved_at, duration, result, error|
        performance_message = {
            sender: sender,
            method: method,
            started_at: initialized_at,
            completed_at: resolved_at,
            duration: duration,
            error: error,
            result: result,
        }.merge(meta_data)
        @logger.write(performance_message)
      end
    end
  end
end
