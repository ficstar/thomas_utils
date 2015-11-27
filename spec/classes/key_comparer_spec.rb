require 'rspec'

module ThomasUtils
  describe KeyComparer do
    describe '#to_s' do
      %w(= > >= <= < !=).each do |comparer|
        context "when #{comparer}" do
          subject { "#{KeyComparer.new(key, comparer)}" }
          let(:key) { :key }
          it { is_expected.to eq("key #{comparer}") }

          context 'with a different key' do
            let(:key) { :different_key }
            it { is_expected.to eq("different_key #{comparer}") }
          end
        end
      end

      context 'when the key is an array' do
        let(:key) { %w(a b c d) }
        subject { "#{KeyComparer.new(key, '>')}" }
        it { is_expected.to eq('(a,b,c,d) >') }

        context 'with a different key' do
          let(:key) { %w(e f g h) }
          it { is_expected.to eq('(e,f,g,h) >') }
        end
      end
    end

    describe '#key' do
      let(:key) { :key }

      subject { KeyComparer.new(key, '>') }

      its(:key) { is_expected.to eq(key) }

      context 'with a different key' do
        let(:key) { :different_key }
        its(:key) { is_expected.to eq(key) }
      end

      context 'with an array key' do
        let(:key) { %w(array of keys) }
        its(:key) { is_expected.to eq(key) }
      end
    end

    describe '#new_key' do
      let(:new_key) { :updated_key }
      subject { "#{KeyComparer.new(:key, '>').new_key(new_key)}" }

      it 'should return an updated KeyComparer with the new key' do
        is_expected.to eq('updated_key >')
      end


      context 'with a different key' do
        let(:new_key) { :different_key }

        it 'should return an updated KeyComparer with the new key' do
          is_expected.to eq('different_key >')
        end
      end
    end
  end
end

describe Symbol do
  {eq: '=', gt: '>', ge: '>=', le: '<=', lt: '<', ne: '!='}.each do |operator, comparer|
    let(:key) { :key }
    describe "##{operator}" do
      subject { "#{key.public_send(operator)}" }
      it { is_expected.to eq("key #{comparer}") }
    end
  end
end

describe Array do
  {eq: '=', gt: '>', ge: '>=', le: '<=', lt: '<', ne: '!='}.each do |operator, comparer|
    let(:key) { %w(lots of keys) }
    describe "##{operator}" do
      subject { "#{key.public_send(operator)}" }
      it { is_expected.to eq("(lots,of,keys) #{comparer}") }
    end
  end
end
