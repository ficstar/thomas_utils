require 'rspec'

module ThomasUtils
  describe Observation do

    let(:value) { Faker::Lorem.word }
    let(:error) { nil }
    let(:executor) { Concurrent::ImmediateExecutor.new }
    let(:observable) { Concurrent::IVar.new }
    let(:observation) { Observation.new(executor, observable) }

    before do
      if error
        observable.fail(error)
      elsif value
        observable.set(value)
      end
    end

    describe '#on_success' do
      let(:result) { [] }
      let(:block) { ->(value) { result << value } }

      subject { observation.on_success(&block) }

      it { is_expected.to eq(observation) }

      it 'should call the block' do
        subject
        expect(result).to eq([value])
      end

      context 'when the observation has failed' do
        let(:error) { StandardError.new }

        it 'should not call the block' do
          subject
          expect(result).to be_empty
        end
      end

      context 'when the value is not immediately ready' do
        let(:value) { nil }
        let(:eventual_value) { Faker::Lorem.word }

        before do
          subject
          observable.set(eventual_value)
        end

        it 'should call the block when complete' do
          expect(result).to eq([eventual_value])
        end
      end
    end

    describe '#on_failure' do
      let(:error) { StandardError.new(Faker::Lorem.word) }
      let(:result) { [] }
      let(:block) { ->(error) { result << error } }

      subject { observation.on_failure(&block) }

      it { is_expected.to eq(observation) }

      it 'should call the block' do
        subject
        expect(result).to eq([error])
      end

      context 'when the observation was successful' do
        let(:error) { nil }

        it 'should not call the block' do
          subject
          expect(result).to be_empty
        end
      end

      context 'when the value is not immediately ready' do
        let(:value) { nil }
        let(:error) { nil }
        let(:eventual_error) { StandardError.new(Faker::Lorem.word) }

        before do
          subject
          observable.fail(eventual_error)
        end

        it 'should call the block when complete' do
          expect(result).to eq([eventual_error])
        end
      end
    end

    describe '#on_complete' do
      let(:result_list) { [] }
      let(:result) { result_list.first }
      let(:block) { ->(value, error) { result_list << [value, error] } }

      subject { observation.on_complete(&block) }

      it { is_expected.to eq(observation) }

      it 'should call the block' do
        subject
        expect(result).to eq([value, nil])
      end

      context 'when the observation has failed' do
        let(:error) { StandardError.new }

        it 'should not call the block' do
          subject
          expect(result).to eq([nil, error])
        end
      end

      context 'when the value is not immediately ready' do
        let(:value) { nil }
        let(:error) { nil }
        let(:eventual_value) { Faker::Lorem.word }

        before do
          subject
          observable.set(eventual_value)
        end

        it 'should call the block when complete' do
          expect(result).to eq([eventual_value, nil])
        end
      end
    end

    describe '#get' do
      subject { observation.get }

      it { is_expected.to eq(value) }

      context 'when the observation has failed' do
        let(:error) { StandardError.new(Faker::Lorem.word) }

        it 'should raise the error' do
          expect { subject }.to raise_error(error)
        end

      end
    end

    describe '#join' do
      subject { observation.join }

      it { is_expected.to eq(observation) }

      it 'should force the observation to complete' do
        expect(observable).to receive(:value)
        subject
      end
    end

    describe '#then' do
      let(:salt) { Faker::Lorem.word }
      let(:value_modifier) { ->(value) { Digest::MD5.base64digest(value + salt) } }
      let(:expected_result) { value_modifier.call(value) }
      let(:block) { ->(value) { value_modifier.call(value) } }

      subject { observation.then(&block) }

      it { is_expected.to be_a_kind_of(Observation) }

      its(:get) { is_expected.to eq(expected_result) }

      context 'when the observation has failed' do
        let(:error) { StandardError.new(Faker::Lorem.word) }

        it 'should raise the error when resolved' do
          expect { subject.get }.to raise_error(error)
        end
      end

      context 'when the block raises an error' do
        let(:block_error) { StandardError.new(Faker::Lorem.word) }
        let(:block) { ->(_) { raise block_error } }

        # an immediate executor would have caused this test to pass immediately,
        # where as an asynchronous one causes a deadlock
        let(:executor) { Concurrent::CachedThreadPool.new }

        it 'should raise the error when resolved' do
          expect { subject.get }.to raise_error(block_error)
        end
      end

      context 'when the block returns an Observation' do
        let(:value_two) { Faker::Lorem.word }
        let(:error_two) { nil }
        let(:observable_two) { Concurrent::IVar.new }
        let(:block) do
          ->(value) do
            Observation.new(executor, observable_two).then do
              value_modifier.call(value)
            end
          end
        end

        before do
          if error_two
            observable_two.fail(error_two)
          elsif value_two
            observable_two.set(value_two)
          end
        end

        its(:get) { is_expected.to eq(expected_result) }

        context 'when the child observation fails' do
          let(:error_two) { StandardError.new(Faker::Lorem.word) }

          it 'should raise the error when resolved' do
            expect { subject.get }.to raise_error(error_two)
          end
        end
      end
    end

    describe '#fallback' do
      let(:error_msg) { Faker::Lorem.sentence }
      let(:error) { StandardError.new(error_msg) }
      let(:error_modifier) { ->(error) { error.message } }
      let(:block) { ->(error) { error_modifier.call(error) } }

      subject { observation.fallback(&block) }

      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to eq(error_msg) }

      context 'when the observation has succeeded' do
        let(:error) { nil }

        it 'should raise the error when resolved' do
          expect(subject.get).to eq(value)
        end
      end

      context 'when the block raises an error' do
        let(:block_error) { StandardError.new(Faker::Lorem.word) }
        let(:block) { ->(_) { raise block_error } }

        # see #then
        let(:executor) { Concurrent::CachedThreadPool.new }

        it 'should raise the error when resolved' do
          expect { subject.get }.to raise_error(block_error)
        end
      end

      context 'when the block returns an Observation' do
        let(:value_two) { Faker::Lorem.word }
        let(:error_two) { nil }
        let(:observable_two) { Concurrent::IVar.new }
        let(:block) do
          ->(error) do
            Observation.new(executor, observable_two).then do
              error_modifier.call(error)
            end
          end
        end

        before do
          if error_two
            observable_two.fail(error_two)
          elsif value_two
            observable_two.set(value_two)
          end
        end

        its(:get) { is_expected.to eq(error_msg) }

        context 'when the child observation fails' do
          let(:error_two) { StandardError.new(Faker::Lorem.word) }

          it 'should raise the error when resolved' do
            expect { subject.get }.to raise_error(error_two)
          end
        end
      end
    end

  end
end
