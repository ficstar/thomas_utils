require 'rspec'

describe Enumerable do

  let(:enum) { (0...100).to_a }

  shared_examples_for 'a result limiting modifier' do
    let(:limit) { rand(0...100) }

    it { is_expected.to be_a_kind_of(ThomasUtils::Enum::Limiter) }
    its(:to_a) { is_expected.to eq(enum[0...limit]) }
  end

  describe '#lazy_limit' do
    subject { enum.lazy_limit(limit) }
    it_behaves_like 'a result limiting modifier'
  end

  describe '#limit' do
    subject { enum.limit(limit) }
    it_behaves_like 'a result limiting modifier'
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

  describe '#lazy_union' do
    let(:enum_two) { (100...200).to_a }
    subject { enum.lazy_union(enum_two) }

    it { is_expected.to be_a_kind_of(ThomasUtils::Enum::Combiner) }
    its(:to_a) { is_expected.to eq(enum.concat(enum_two)) }
  end

  describe '#lazy_uniq' do
    let(:enum) { [0, 1, 1, 2, 2, 3] }
    subject { enum.lazy_uniq }

    it { is_expected.to be_a_kind_of(ThomasUtils::Enum::MakeUnique) }
    its(:to_a) { is_expected.to eq((0..3).to_a) }

    context 'with a block provided' do
      let(:block) { ->(item) { item % 2 == 0 } }
      subject { enum.lazy_uniq(&block) }

      its(:to_a) { is_expected.to eq([0, 1]) }

      context 'when the block is provided as a parameter' do
        subject { enum.lazy_uniq(block) }

        its(:to_a) { is_expected.to eq([0, 1]) }
      end
    end
  end

end
