require 'spec_helper'

module ThomasUtils
  describe PeriodicFlusher do

    class PeriodicFlusher
      def self.reset!
        @@streams = {}
      end
    end

    let(:timeout) { 1 }
    let(:stream) { double(:stream, flush: nil) }
    before do
      PeriodicFlusher.reset!
      allow(Workers::PeriodicTimer).to receive(:new).with(timeout).and_yield
    end

    describe '.<<' do
      it 'should periodically call flush on the stream' do
        expect(stream).to receive(:flush)
        PeriodicFlusher << {name: :stream, stream: stream}
      end

      it 'should not save the stream more than once' do
        PeriodicFlusher << {name: :stream, stream: stream}
        expect(stream).not_to receive(:flush)
        PeriodicFlusher << {name: :stream, stream: stream}
      end

      context 'with a different timeout' do
        let(:timeout) { 2 }

        it 'should use a different timeout if specified' do
          expect(Workers::PeriodicTimer).to receive(:new).with(timeout)
          PeriodicFlusher << {name: :stream, stream: stream, timeout: timeout}
        end
      end
    end

    describe '.[]' do
      let(:name) { :stream }
      subject { PeriodicFlusher[name] }

      before { PeriodicFlusher << {name: name, stream: stream} }

      it 'should return a previously saved stream' do
        expect(subject).to eq(stream)
      end

      context 'with a different name' do
        let(:name) { :other_stream }
        it { should == stream }
      end
    end
  end
end