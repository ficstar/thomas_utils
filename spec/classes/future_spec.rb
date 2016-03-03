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


    describe 'execution' do
      it { expect(Future::DEFAULT_EXECUTOR).to be_a_kind_of(Concurrent::CachedThreadPool) }

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
