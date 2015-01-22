require 'rspec'

describe FutureWrapper do
  class Future
    def join

    end

    def get
      'value'
    end
  end

  let(:future) { Future.new }
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
  end
end