require 'rspec'

module ThomasUtils
  describe ExecutorCollection do

    let(:collection) { ExecutorCollection.new }

    shared_examples_for 'an executor collection' do
      describe '#build' do
        let(:name) { Faker::Lorem.sentence }
        let(:max_threads) { rand(1..100) }
        let(:max_queue) { rand(100..5000) }

        subject { collection[name] }

        before { collection.build(name, max_threads, max_queue) }

        it { is_expected.to be_a_kind_of(Concurrent::ThreadPoolExecutor) }
        its(:min_length) { is_expected.to be_zero }
        its(:max_length) { is_expected.to eq(max_threads) }
        its(:max_queue) { is_expected.to eq(max_queue) }
        its(:fallback_policy) { is_expected.to eq(:caller_runs) }
        its(:auto_terminate?) { is_expected.to eq(true) }
      end
    end

    it_behaves_like 'an executor collection'

    describe 'the default collection' do
      let(:collection) { ExecutorCollection }

      it_behaves_like 'an executor collection'
    end

  end
end
