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