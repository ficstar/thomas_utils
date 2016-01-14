require 'rspec'

module ThomasUtils
  describe KeyIndexer do
    subject { KeyIndexer.new(:key, 'value') }

    it { is_expected.to be_a_kind_of(SymbolHelpers) }

    %w(Address Details).each do |key|
      %w(Name Street).each do |index|
        context "when the key is #{key}" do
          context "when the index is #{index}" do
            describe '#to_s' do
              subject { "#{KeyIndexer.new(key, index)}" }
              it { is_expected.to eq("#{key}['#{index}']") }
            end
          end

          describe '#key' do
            subject { KeyIndexer.new(key, index).key }
            it { is_expected.to eq(key) }
          end
        end
      end
    end

    describe 'comparison' do
      let(:klass) { KeyIndexer }
      it_behaves_like 'defining hashing methods for a key'
    end

  end
end

describe Symbol do
  describe '#index' do
    subject { "#{:hello.index(:world)}" }
    it { is_expected.to eq("hello['world']") }
  end
end
