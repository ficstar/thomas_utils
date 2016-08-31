require 'rspec'

describe Mutex do
  describe '#synchronize_unless_owned' do
    it 'yields' do
      expect { |block| subject.synchronize_unless_owned(&block) }.to yield_control
    end

    it 'locks before yielding' do
      subject.synchronize_unless_owned do
        expect(subject).to be_owned
      end
    end

    it 'unlocks after yielding' do
      subject.synchronize_unless_owned {}
      expect(subject).not_to be_owned
    end

    it 'supports recursive synchronization' do
      expect do
        subject.synchronize_unless_owned do
          subject.synchronize_unless_owned {}
        end
      end.not_to raise_error
    end
  end
end
