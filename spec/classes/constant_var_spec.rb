require 'rspec'

module ThomasUtils
  describe ConstantVar do

    let(:time) { Time.now }
    let(:value) { Faker::Lorem.word }
    let(:error) { Faker::Lorem.word }
    let(:observer) { double(:observer, update: nil) }

    subject { ConstantVar.new(time, value, error) }

    describe '#add_observer' do
      it 'should call the update method on the observer with the initialization params' do
        expect(observer).to receive(:update).with(time, value, error)
        subject.add_observer(observer)
      end

      context 'with a different update method' do
        let(:update_method) { Faker::Lorem.word.to_sym }

        it 'should call that method' do
          expect(observer).to receive(update_method).with(time, value, error)
          subject.add_observer(observer, update_method)
        end
      end

      context 'when provided with a block' do
        it 'should call the block' do
          expect(observer).to receive(:update).with(time, value, error)
          subject.add_observer { |time, value, error| observer.update(time, value, error) }
        end
      end
    end

  end
end
