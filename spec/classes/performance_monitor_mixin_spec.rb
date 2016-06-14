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
    end

    describe '#performance_monitor' do
      before { PerformanceMonitorMixin.monitor = monitor }
      subject { test_object.performance_monitor }
      it { is_expected.to eq(monitor) }
    end

    describe '#monitor_performance' do
      let(:method) { Faker::Lorem.word.to_sym }
      let(:monitor_name) { Faker::Lorem.sentence }
      let(:item) { double(:future) }
      let(:block_result) { Faker::Lorem.sentence }
      let(:block) do
        result = block_result
        lambda { result }
      end

      it 'should return a given future' do
        expect(test_object.monitor_performance(method, monitor_name, item)).to eq(item)
      end

      context 'with a block given' do
        it 'should return an Observation' do
          expect(test_object.monitor_performance(method, monitor_name, &block)).to be_a_kind_of(Observation)
        end

        it 'should return a future resolving to the result of the block' do
          expect(test_object.monitor_performance(method, monitor_name, &block).get).to eq(block_result)
        end
      end

      context 'with a monitor' do
        before { PerformanceMonitorMixin.monitor = monitor }

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
end
