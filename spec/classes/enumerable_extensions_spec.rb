require 'rspec'

describe Enumerable do

  let(:enum) { (0...100).to_a }

  describe '#lazy_limit' do
    let(:limit) { rand(0...100) }
    subject { enum.lazy_limit(limit) }

    it { is_expected.to be_a_kind_of(ThomasUtils::Enum::Limiter) }
    its(:to_a) { is_expected.to eq(enum[0...limit]) }
  end

end
