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

  end
end
