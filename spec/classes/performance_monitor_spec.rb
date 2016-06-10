require 'rspec'

module ThomasUtils
  describe PerformanceMonitor do

    let(:logger_klass) do
      Class.new do
        attr_reader :log
        define_method(:initialize) { @log = [] }
        define_method(:write) { |entry| @log << entry }
      end
    end
    let(:logger) { logger_klass.new }
    let(:monitor) { PerformanceMonitor.new(logger) }

    describe '#monitor' do
      let(:sender) { double(:sender) }
      let(:method) { Faker::Lorem.word.to_sym }
      let(:monitor_name) { Faker::Lorem.sentence }
      let(:initialized_at) { Time.now }
      let(:duration) { rand * 60 }
      let(:resolved_at) { initialized_at + duration }
      let(:const_var) { ConstantVar.new(resolved_at, nil, nil) }
      let(:future) { Observation.new(Future::IMMEDIATE_EXECUTOR, const_var, initialized_at) }
      let(:log_item) do
        {
            sender: sender,
            method: method,
            name: monitor_name,
            started_at: initialized_at,
            completed_at: resolved_at,
            duration: duration,
        }
      end

      subject { logger.log }

      before do
        monitor.monitor(sender, method, monitor_name, future)
        future.get
      end

      it { is_expected.to include(log_item) }
    end
  end
end
