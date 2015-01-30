require 'rspec'

module ThomasUtils
  describe MultiFutureWrapper do
    let(:future) { MockFuture.new }
    let(:futures) { [future] }
    let(:proc) { ->{} }

    subject { MultiFutureWrapper.new(futures, &proc) }

    describe '#join' do
      it 'should join all of the futures' do
        expect(future).to receive(:join)
        subject.join
      end

      context 'with multiple futures' do
        let(:other_future) { MockFuture.new }
        let(:futures) { [future, other_future] }

        it 'should join all of the futures' do
          expect(other_future).to receive(:join)
          subject.join
        end
      end
    end

    describe '#get' do
      let(:proc) { ->(row) { "some #{row}" } }

      it 'should return the value of the block evaluated with the resolve futures' do
        expect(subject.get).to eq(['some value'])
      end

      context 'with multiple futures' do
        let(:other_future) { MockFuture.new }
        let(:futures) { [future, other_future] }

        it 'should return the value of the block evaluated with the resolve futures' do
          expect(subject.get).to eq(['some value', 'some value'])
        end
      end
    end
  end
end