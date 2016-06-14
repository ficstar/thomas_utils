module ThomasUtils
  module PerformanceMonitorMixin
    class << self
      attr_accessor :monitor
    end

    def performance_monitor
      PerformanceMonitorMixin.monitor
    end

    def monitor_performance(method, monitor_name, item = nil, &block)
      performance_monitor.monitor(self, method, monitor_name, item, &block)
    end
  end
end
