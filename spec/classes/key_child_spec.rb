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

    describe '#quote' do
      let(:key) { Faker::Lorem.word }
      let(:value) { Faker::Lorem.word }
      let(:quote) { '`' }
      let(:quoted_key) { "`#{key}`.`#{value}`" }

      subject { KeyChild.new(key, value).quote(quote) }

      it { is_expected.to eq(quoted_key) }

      context 'with a different quote type' do
        let(:quote) { '"' }
        let(:quoted_key) { %Q{"#{key}"."#{value}"} }

        it { is_expected.to eq(quoted_key) }
      end

      context 'when the key itself is a KeyChild' do
        let(:key) { KeyChild.new(Faker::Lorem.word, Faker::Lorem.word) }
        let(:quoted_key) { "`#{key.key}`.`#{key.child}`.`#{value}`" }

        it { is_expected.to eq(quoted_key) }
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
