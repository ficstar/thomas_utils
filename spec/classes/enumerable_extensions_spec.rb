require 'rspec'

describe Enumerable do

  let(:enum) { (0...100).to_a }

  describe '#lazy_limit' do
    let(:limit) { rand(0...100) }
    subject { enum.lazy_limit(limit) }

    it { is_expected.to be_a_kind_of(ThomasUtils::Enum::Limiter) }
    its(:to_a) { is_expected.to eq(enum[0...limit]) }
  end

  describe '#lazy_filter' do
    let(:limit) { rand(0...100) }
    let(:filter) { ->(item) { item < limit } }
    subject { enum.lazy_filter(&filter) }

    it { is_expected.to be_a_kind_of(ThomasUtils::Enum::Filter) }
    its(:to_a) { is_expected.to eq(enum.select(&filter)) }

    context 'when passed in as a parameter instead of a block' do
      subject { enum.lazy_filter(filter) }

      it { is_expected.to be_a_kind_of(ThomasUtils::Enum::Filter) }
      its(:to_a) { is_expected.to eq(enum.select(&filter)) }
    end
  end

end
