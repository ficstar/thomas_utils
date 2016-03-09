require 'rspec'

module ThomasUtils
  describe ConstantVar do

    let(:time) { Time.now }
    let(:value) { Faker::Lorem.word }
    let(:error) { StandardError.new(Faker::Lorem.word) }
    let(:observer) { double(:observer, update: nil) }
    let(:cvar) { ConstantVar.new(time, value, error) }

    subject { cvar }

    describe 'helper methods' do
      around { |example| Timecop.freeze { example.run } }

      describe '.value' do
        it { expect(ConstantVar.value(value)).to eq(ConstantVar.new(Time.now, value, nil)) }
      end

      describe '.none' do
        it { expect(ConstantVar.none).to eq(ConstantVar.new(Time.now, nil, nil)) }
      end

      describe '.error' do
        it { expect(ConstantVar.error(error)).to eq(ConstantVar.new(Time.now, nil, error)) }
      end
    end

    describe '#value' do
      subject { cvar.value }
      it { is_expected.to eq(value) }
    end

    describe '#reason' do
      subject { cvar.reason }
      it { is_expected.to eq(error) }
    end

    describe '#value!' do
      let(:error) { nil }
      subject { cvar.value! }

      it { is_expected.to eq(value) }

      context 'with an error' do
        let(:error) { StandardError.new(Faker::Lorem.word) }
        it { expect { subject }.to raise_error(error) }
      end
    end

    shared_examples_for 'a method adding an observer' do |method|
      it 'should call the update method on the observer with the initialization params' do
        expect(observer).to receive(:update).with(time, value, error)
        subject.public_send(method, observer)
      end

      context 'with a different update method' do
        let(:update_method) { Faker::Lorem.word.to_sym }

        it 'should call that method' do
          expect(observer).to receive(update_method).with(time, value, error)
          subject.public_send(method, observer, update_method)
        end
      end

      context 'when provided with a block' do
        it 'should call the block' do
          expect(observer).to receive(:update).with(time, value, error)
          subject.public_send(method) { |time, value, error| observer.update(time, value, error) }
        end
      end
    end

    describe '#add_observer' do
      it_behaves_like 'a method adding an observer', :add_observer
    end

    describe '#with_observer' do
      it_behaves_like 'a method adding an observer', :with_observer

      it 'should return the observable' do
        expect(subject.with_observer(observer)).to eq(subject)
      end
    end

    shared_examples_for 'an unimplemented method' do
      it { expect { subject }.to raise_error(NotImplementedError) }
    end

    describe '#delete_observer' do
      subject { cvar.delete_observer(observer) }
      it_behaves_like 'an unimplemented method'
    end

    describe '#delete_observers' do
      subject { cvar.delete_observers }
      it_behaves_like 'an unimplemented method'
    end

    describe '#count_observers' do
      subject { cvar.count_observers }
      it_behaves_like 'an unimplemented method'
    end

  end
end
