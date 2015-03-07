require 'rspec'

module ThomasUtils
  describe Future do
    let(:block) { good_block }
    let(:good_block) { -> { 'Hello, World!' } }
    let(:error_block) { -> { raise 'Goodbye, World!' } }
    let(:future_wrapper) { Future.new(&block) }
    let(:fulfilled) { true }
    let(:future_options) { { } }
    let(:future) do
      future = double(:future, fulfilled?: fulfilled)
      allow(future).to receive(:value) { future_options[:value] }
      future
    end
    let!(:result_id) { SecureRandom.uuid }

    before do
      expect(::Concurrent::Future).to receive(:execute).with(executor: Future::EXECUTOR) do |&block|
        future_options[:value] = block.call
      end.and_return(future)
    end

    describe '#get' do
      subject { future_wrapper.get }

      it 'should be the value of the specified block' do
        is_expected.to eq('Hello, World!')
      end

      context 'with a different value' do
        let(:good_block) { -> { 'Goodbye, World!' } }

        it 'should be the value of the specified block' do
          is_expected.to eq('Goodbye, World!')
        end
      end

      context 'when the block raises an error' do
        let(:block) { error_block }

        it 'should re-raise the error' do
          expect { subject }.to raise_error('Goodbye, World!')
        end
      end

      context 'when the result is a future wrapper' do
        let(:result_future) { double(:future, get: 'Hello, World!') }
        let(:result_future_wrapper) { FutureWrapper.new(result_future) { |res| res } }
        let(:good_block) { -> { result_future_wrapper } }

        it 'should return the result of that future' do
          is_expected.to eq('Hello, World!')
        end
      end
    end

    describe '#on_success' do
      it 'should yield the value' do
        expect { |block| future_wrapper.on_success(&block) }.to yield_with_args('Hello, World!')
      end

      context 'when the block raises an error' do
        let(:block) { error_block }

        it 'should not yield' do
          expect { |block| future_wrapper.on_success(&block) }.not_to yield_control
        end
      end

      context 'when called after the block is already executed' do
        before { future_wrapper.get rescue nil }

        it 'should yield the value' do
          expect { |block| future_wrapper.on_success(&block) }.to yield_with_args('Hello, World!')
        end

        context 'when the block raises an error' do
          let(:block) { error_block }

          it 'should not yield' do
            expect { |block| future_wrapper.on_success(&block) }.not_to yield_control
          end
        end
      end
    end

    describe '#on_failure' do
      let(:error) { RuntimeError.new('Goodbye, World!') }
      let(:error_block) { -> { raise error } }

      it 'should not yield by default' do
        expect { |block| future_wrapper.on_failure(&block) }.not_to yield_control
      end

      context 'when the block raises an error' do
        let(:block) { error_block }

        it 'should call the block with the provided error' do
          expect { |block| future_wrapper.on_failure(&block) }.to yield_with_args(error)
        end
      end

      context 'when called after the block is already executed' do
        before { future_wrapper.get rescue nil }

        it 'should not yield by default' do
          expect { |block| future_wrapper.on_failure(&block) }.not_to yield_control
        end

        context 'when the block raises an error' do
          let(:block) { error_block }

          it 'should call the block with the provided error' do
            expect { |block| future_wrapper.on_failure(&block) }.to yield_control
          end
        end
      end
    end

  end
end