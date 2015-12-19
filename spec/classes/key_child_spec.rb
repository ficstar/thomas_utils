require 'rspec'

module ThomasUtils
  describe KeyChild do
    subject { KeyChild.new(:key, :value) }

    it { is_expected.to be_a_kind_of(SymbolHelpers) }

    %w(Address Details).each do |key|
      %w(Name Street).each do |child|
        context "when the key is #{key}" do
          context "when the child is #{child}" do
            describe '#to_s' do
              subject { "#{KeyChild.new(key, child)}" }
              it { is_expected.to eq("#{key}.#{child}") }
            end
          end

          describe '#key' do
            subject { KeyChild.new(key, child).key }
            it { is_expected.to eq(key) }
          end

          describe '#child' do
            subject { KeyChild.new(key, child).child }
            it { is_expected.to eq(child) }
          end
        end
      end
    end
  end
end

describe Symbol do
  describe '#child' do
    subject { "#{:hello.child(:world)}" }
    it { is_expected.to eq('hello.world') }
  end
end
