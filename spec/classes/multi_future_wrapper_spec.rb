require 'rspec'

module ThomasUtils
  describe MultiFutureWrapper do
    let(:future) { MockFuture.new }
    let(:other_future) { MockFuture.new }
    let(:futures) { [future] }
    let(:proc) { ->(row) { "some #{row}" } }

    subject { MultiFutureWrapper.new(futures, &proc) }

    describe '#join' do
      it 'should join all of the futures' do
        expect(future).to receive(:join)
        subject.join
      end

      context 'with multiple futures' do
        let(:futures) { [future, other_future] }

        it 'should join all of the futures' do
          expect(other_future).to receive(:join)
          subject.join
        end
      end
    end

    describe '#on_failure' do
      let(:rescue_block) { -> {} }

      it 'should delegate to the future' do
        expect(future).to receive(:on_failure) do |&block|
          expect(block).to eq(rescue_block)
        end
        subject.on_failure(&rescue_block)
      end

      context 'with multiple futures' do
        let(:futures) { [future, other_future] }

        it 'should delegate to all futures' do
          expect(other_future).to receive(:on_failure) do |&block|
            expect(block).to eq(rescue_block)
          end
          subject.on_failure(&rescue_block)
        end
      end
    end

    describe '#on_success' do
      it 'should call the wrapping block and yield the result to the callback' do
        resulting_value = nil
        subject.on_success { |result| resulting_value = result }
        expect(resulting_value).to eq("some #{future.get}")
      end

      context 'with multiple futures' do
        let(:futures) { [future, other_future] }

        it 'should yield for each future' do
          resulting_value = []
          subject.on_success { |result| resulting_value << result }
          expect(resulting_value).to eq(["some #{future.get}", "some #{future.get}"])
        end
      end
    end

    describe '#get' do
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