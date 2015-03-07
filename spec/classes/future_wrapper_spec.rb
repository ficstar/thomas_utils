require 'rspec'

module ThomasUtils
  describe FutureWrapper do
    let(:future) { MockFuture.new }
    let(:wrapper) do
      FutureWrapper.new(future) { |value| "some #{value}" }
    end

    describe '#join' do
      it 'should delegate to the future' do
        expect(future).to receive(:join)
        wrapper.join
      end
    end

    describe '#on_failure' do
      let(:rescue_block) { ->{} }

      it 'should delegate to the future' do
        expect(future).to receive(:on_failure) do |&block|
          expect(block).to eq(rescue_block)
        end
        wrapper.on_failure(&rescue_block)
      end
    end

    describe '#on_success' do
      it 'should call the wrapping block and yield the result to the callback' do
        resulting_value = nil
        wrapper.on_success { |result| resulting_value = result }
        expect(resulting_value).to eq("some #{future.get}")
      end
    end

    describe '#get' do
      it 'should return the value of the block called with the resolved future' do
        expect(wrapper.get).to eq("some #{future.get}")
      end

      it 'should cache the result' do
        wrapper.get
        expect(future).not_to receive(:get)
        wrapper.get
      end
    end
  end
end