shared_examples_for 'a method comparing two keys' do |method|
  describe "##{method}" do
    let(:key) { Faker::Lorem.word }
    let(:value) { Faker::Lorem.word }
    let(:lhs) { klass.new(key, value) }
    let(:rhs) { klass.new(key, value) }

    subject { lhs.public_send(method, rhs) }

    it { is_expected.to eq(true) }

    context 'when the value of one is different from the other' do
      let(:rhs) { klass.new(key, Faker::Lorem.sentence) }
      it { is_expected.to eq(false) }
    end

    context 'when the key of one is different from the other' do
      let(:rhs) { klass.new(Faker::Lorem.sentence, value) }
      it { is_expected.to eq(false) }
    end

    context 'when the right side is of the wrong type' do
      let(:rhs) { String }
      it { is_expected.to eq(false) }
    end
  end
end

shared_examples_for 'a method delegating #hash to the hash of #to_s' do
  describe '#hash' do
    let(:key) { klass.new(Faker::Lorem.word, Faker::Lorem.word) }
    subject { key }

    its(:hash) { is_expected.to eq(key.to_s.hash) }
  end
end

shared_examples_for 'defining hashing methods for a key' do
  it_behaves_like 'a method comparing two keys', :==
  it_behaves_like 'a method comparing two keys', :eql?
  it_behaves_like 'a method delegating #hash to the hash of #to_s'
end
