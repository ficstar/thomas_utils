require 'rspec'

module ThomasUtils
  describe KeyComparer do
    describe '#to_s' do
      %w(= > >= <= < !=).each do |comparer|
        context "when #{comparer}" do
          let(:key) { :key }
          subject { "#{KeyComparer.new(key, comparer)}" }
          it { is_expected.to eq("key #{comparer}") }

          context 'with a different key' do
            let(:key) { :different_key }
            it { is_expected.to eq("different_key #{comparer}") }
          end
        end
      end
    end

  end

  describe Symbol do
    {eq: '=', gt: '>', ge: '>=', le: '<=', lt: '<', ne: '!='}.each do |operator, comparer|
      let(:key) { :key }
      describe "##{operator}" do
        subject { "#{:key.send(operator)}" }
        it { is_expected.to eq("key #{comparer}") }
      end
    end
  end
end