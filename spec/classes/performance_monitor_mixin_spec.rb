require 'rspec'

module ThomasUtils
  describe PerformanceMonitorMixin do

    module PerformanceMonitorMixin
      def self.reset!
        @monitor = nil
      end
    end

    let(:monitoring_klass) do
      Class.new { include PerformanceMonitorMixin }
    end
    let(:test_object) { monitoring_klass.new }
    let(:mock_logger) { double(:logger, write: :nil) }
    let(:monitor) { PerformanceMonitor.new(mock_logger) }

    before do
      PerformanceMonitorMixin.reset!
      PerformanceMonitorMixin.monitor = monitor
    end

    describe '#performance_monitor' do
      subject { test_object.performance_monitor }
      it { is_expected.to eq(monitor) }
    end

    describe '#monitor_performance' do
      let(:method) { Faker::Lorem.word.to_sym }
      let(:monitor_name) { Faker::Lorem.sentence }
      let(:item) { double(:future) }
      let(:block) { lambda {} }

      it 'should measure the performance of a provided future' do
        expect(monitor).to receive(:monitor).with(test_object, method, monitor_name, item)
        test_object.monitor_performance(method, monitor_name, item)
      end

      it 'should measure the performance of a provided block' do
        expect(monitor).to receive(:monitor).with(test_object, method, monitor_name, nil) do |&result_block|
          expect(result_block).to eq(block)
        end
        test_object.monitor_performance(method, monitor_name, &block)
      end
    end

  end
end
