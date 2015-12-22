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

    describe '#new_key' do
      let(:key) { Faker::Lorem.word }
      let(:value) { Faker::Lorem.word }
      let(:new_key) { Faker::Lorem.word }
      let(:new_key_child) { KeyChild.new(new_key, value) }

      subject { KeyChild.new(key, value).new_key(new_key) }

      its(:to_s) { is_expected.to eq(new_key_child.to_s) }
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

      context 'when the key itself responds to #quote' do
        let(:key_key) { Faker::Lorem.word }
        let(:key_value) { Faker::Lorem.word }
        let(:key) { double(:quoted_key) }
        let(:quoted_key) { "`#{key_key}`.`#{key_value}`.`#{value}`" }

        before do
          allow(key).to receive(:quote) do |quote|
            "#{quote}#{key_key}#{quote}.#{quote}#{key_value}#{quote}"
          end
        end

        it { is_expected.to eq(quoted_key) }
      end
    end
  end
end

describe Symbol do
  [:>>, :child].each do |method|
    describe "##{method}" do
      subject { "#{:hello.public_send(method, :world)}" }
      it { is_expected.to eq('hello.world') }
    end
  end
end
