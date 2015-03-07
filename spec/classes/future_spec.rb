require 'rspec'

module ThomasUtils
  describe Future do
    let(:block) { good_block }
    let(:good_block) { -> { 'Hello, World!' } }
    let(:error_block) { -> { raise 'Goodbye, World!' } }
    let(:future_wrapper) { Future.new(&block) }
    let(:fulfilled) { true }
    let(:future) { double(:future, fulfilled?: fulfilled, value: futurize(good_block.call)) }
    let!(:result_id) { SecureRandom.uuid }

    def futurize(value)
      "(tag: #{result_id}) FUTURE OF #{value}"
    end

    before do
      expect(::Concurrent::Future).to receive(:execute).and_yield.and_return(future)
    end

    describe '#get' do
      subject { future_wrapper.get }

      it 'should be the value of the specified block' do
        is_expected.to eq(futurize('Hello, World!'))
      end

      context 'with a different value' do
        let(:good_block) { -> { 'Goodbye, World!' } }

        it 'should be the value of the specified block' do
          is_expected.to eq(futurize('Goodbye, World!'))
        end
      end

      context 'when the block raises an error' do
        let(:block) { error_block }

        it 'should re-raise the error' do
          expect { subject }.to raise_error('Goodbye, World!')
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