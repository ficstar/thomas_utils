require 'rspec'

module ThomasUtils
  describe ConstantVar do

    let(:time) { Time.now }
    let(:value) { Faker::Lorem.word }
    let(:error) { Faker::Lorem.word }
    let(:observer) { double(:observer, update: nil) }

    subject { ConstantVar.new(time, value, error) }

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

  end
end
