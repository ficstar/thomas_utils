shared_examples_for '#respond_to? for an Enumerable modifier' do
  let(:enum) { double(:enum) }
  let(:respond_method) { :each }
  let(:include_all) { rand(0..1).nonzero? }

  subject { enum_modifier.respond_to?(respond_method, include_all) }

  it { is_expected.to eq(true) }

  context 'without including everything' do
    subject { enum_modifier.respond_to?(respond_method) }

    it { is_expected.to eq(true) }
  end

  context 'with an unsupported method' do
    let(:respond_method) { Faker::Lorem.word }

    it { is_expected.to eq(false) }

    context 'when the underlying enum supports that method' do
      before { allow(enum).to receive(:respond_to?).with(respond_method, include_all).and_return(true) }

      it { is_expected.to eq(true) }
    end
  end
end

shared_examples_for '#method_missing for an Enumerable modifier' do
  let(:respond_method) { Faker::Lorem.word.to_sym }
  let(:enum_two) { Faker::Lorem.words }
  let(:enum) { double(:enum) }
  let(:args) { Faker::Lorem.words }
  let(:block) { ->() {} }

  subject { enum_modifier.public_send(respond_method, *args, &block) }

  before do
    allow(enum).to receive(respond_method).with(*args).and_return(enum_two)
  end

  it { is_expected.to be_a_kind_of(enum_modifier_klass) }

  its(:to_a) { is_expected.to eq(result_enum_modifier.to_a) }

  context 'with a block required' do
    let(:some_double) { double(:some_double, call: nil) }
    let(:block) { ->() { some_double.call } }

    before do
      allow(enum).to receive(respond_method).and_yield
    end

    it 'should pass the block' do
      expect(some_double).to receive(:call)
      subject
    end
  end
end
