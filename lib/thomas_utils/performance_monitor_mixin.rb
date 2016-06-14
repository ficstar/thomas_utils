module ThomasUtils
  module PerformanceMonitorMixin
    class << self
      attr_accessor :monitor
    end

    def performance_monitor
      PerformanceMonitorMixin.monitor
    end

    def monitor_performance(method, monitor_name, item = nil, &block)
      if performance_monitor
        performance_monitor.monitor(self, method, monitor_name, item, &block)
      else
        item ? item : Future.immediate(&block)
      end
    end
  end
end
