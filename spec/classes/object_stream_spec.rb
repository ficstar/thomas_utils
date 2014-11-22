require 'spec_helper'

describe ObjectStream do
  class ObjectStream
    attr_reader :buffer
  end

  subject { ObjectStream.new(proc) }
  let(:proc) { Proc.new {} }

  describe '#<<' do
    it 'should buffer the data' do
      subject << 'hello'
      expect(subject.buffer.pop).to eq('hello')
    end
  end

  describe '#flush' do
    let(:proc) { double(:proc) }

    it 'should call the provided procedure with all current available data' do
      subject << 'hello'
      expect(proc).to receive(:call).with(%w(hello))
      subject.flush
    end

    context 'with multiple buffered items' do
      it 'should call the procedure with all buffered items' do
        subject << 'hello'
        subject << 'world'
        expect(proc).to receive(:call).with(%w(hello world))
        subject.flush
      end
    end
  end
end