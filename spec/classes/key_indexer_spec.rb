require 'rspec'

module ThomasUtils
  describe KeyIndexer do
    describe '#to_s' do
      %w(Address Details).each do |key|
        %w(Name Street).each do |index|
          context "when the key is #{key} and the index is #{index}" do
            subject { "#{KeyIndexer.new(key, index)}" }
            it { is_expected.to eq("#{key}[#{index}]") }
          end
        end
      end
    end
  end
end

describe Symbol do
  describe '#index' do
    subject { "#{:hello.index(:world)}" }
    it { is_expected.to eq('hello[world]') }
  end
end
