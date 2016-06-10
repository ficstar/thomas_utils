require 'rspec'

module ThomasUtils
  describe Future do

    let(:value) { Faker::Lorem.word }
    let(:block_result) { [] }
    let(:block) { ->() { block_result << value; value } }
    let(:executor) { nil }
    let(:result_executor) { executor || DEFAULT_EXECUTOR }
    let(:options) do
      {}.tap do |options|
        options[:executor] = executor if executor
      end
    end
    let(:future) { Future.new(options, &block) }

    subject { future }

    before do
      allow(Future::DEFAULT_EXECUTOR).to receive(:post) { |&block| block.call }
    end

    it { is_expected.to be_a_kind_of(Observation) }

    describe '.value' do
      subject { Future.value(value) }
      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to eq(value) }
    end

    describe '.immediate' do
      let(:immediate_block) { ->() { value } }
      subject { Future.immediate(&immediate_block) }
      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to eq(value) }

      describe 'timing the block' do
        let(:expected_start_time) { Time.now }
        let(:expected_resolution_time) { expected_start_time + 5 * 60 }
        let(:mock_observation) { double(:observation, get: value) }

        it 'should time the block properly' do
          expect(Time).to receive(:now).and_return(expected_start_time).ordered
          expect(immediate_block).to receive(:call).and_call_original.ordered
          allow(Time).to receive(:now).and_return(expected_resolution_time).ordered
          expect(Observation).to receive(:new).with(anything, anything, expected_start_time).and_return(mock_observation).ordered
          subject.get
        end
      end
    end

    describe '.none' do
      subject { Future.none }
      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to be_nil }
    end

    describe '.error' do
      let(:error) { StandardError.new(Faker::Lorem.sentence) }
      subject { Future.error(error) }
      it { is_expected.to be_a_kind_of(Observation) }
      it { expect { subject.get }.to raise_error(error) }
    end

    describe '.all' do
      let(:future) { Future.value(value) }
      let(:list_of_futures) { [future] }

      subject { Future.all(list_of_futures) }

      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to eq([value]) }

      context 'with multiple futures' do
        let(:value_two) { Faker::Lorem.sentence }
        let(:future_two) { Future.value(value_two) }
        let(:list_of_futures) { [future, future_two] }

        its(:get) { is_expected.to eq([value, value_two]) }
      end

      context 'with an error' do
        let(:error) { StandardError.new(Faker::Lorem.sentence) }
        let(:future) { Future.error(error) }

        it { expect { subject.get }.to raise_error(error) }
      end

      describe 'timing the futures' do
        let(:initialized_at) { Time.now }
        let(:future) { Observation.new(Future::IMMEDIATE_EXECUTOR, ConstantVar.value(value), initialized_at) }

        its(:initialized_at) { is_expected.to eq(initialized_at) }

        context 'with multiple futures' do
          let(:initialized_at_two) { initialized_at - 3 }
          let(:value_two) { Faker::Lorem.sentence }
          let(:future_two) { Observation.new(Future::IMMEDIATE_EXECUTOR, ConstantVar.value(value_two), initialized_at_two) }
          let(:list_of_futures) { [future, future_two] }

          its(:initialized_at) { is_expected.to eq(initialized_at_two) }

          context 'when the other future is behind' do
            let(:initialized_at_two) { initialized_at + 71 }

            its(:initialized_at) { is_expected.to eq(initialized_at) }
          end
        end
      end
    end

    describe 'execution' do
      it { expect(Future::DEFAULT_EXECUTOR).to be_a_kind_of(Concurrent::CachedThreadPool) }
      it { expect(Future::IMMEDIATE_EXECUTOR).to be_a_kind_of(Concurrent::ImmediateExecutor) }

      it 'should use execute within the default executor context' do
        expect(Future::DEFAULT_EXECUTOR).to receive(:post) do |&block|
          block.call
          expect(block_result).to eq([value])
        end
        subject
      end

      it 'should support chained executions' do
        salt = Faker::Lorem.word
        expect(subject.then { |result| [result, salt] }.get).to eq([value, salt])
      end

      context 'with a specific executor' do
        let(:executor) { Concurrent::ImmediateExecutor.new }

        before { allow(Future::DEFAULT_EXECUTOR).to receive(:post) }

        it 'should use execute within the default executor context' do
          subject
          expect(block_result).to eq([value])
        end

        it 'should support chained executions' do
          salt = Faker::Lorem.word
          expect(subject.then { |result| [result, salt] }.get).to eq([value, salt])
        end
      end
    end

  end
end
