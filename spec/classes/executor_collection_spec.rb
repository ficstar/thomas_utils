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

      describe '#stats' do
        let(:name) { Faker::Lorem.sentence }
        let(:max_threads) { rand(1..100) }
        let(:max_queue) { rand(100..5000) }
        let(:largest_length) { rand(1..max_threads) }
        let(:scheduled_task_count) { rand(1..max_queue) }
        let(:completed_task_count) { rand(1..scheduled_task_count) }
        let(:queue_length) { rand(1..completed_task_count) }

        before do
          collection.build(name, max_threads, max_queue)
          allow_any_instance_of(Concurrent::ThreadPoolExecutor).to receive(:largest_length).and_return(largest_length)
          allow_any_instance_of(Concurrent::ThreadPoolExecutor).to receive(:scheduled_task_count).and_return(scheduled_task_count)
          allow_any_instance_of(Concurrent::ThreadPoolExecutor).to receive(:completed_task_count).and_return(completed_task_count)
          allow_any_instance_of(Concurrent::ThreadPoolExecutor).to receive(:queue_length).and_return(queue_length)
        end

        subject { collection.stats[name] }

        it { is_expected.to include(maximum_active_tasks: max_threads) }
        it { is_expected.to include(maximum_queued_tasks: max_queue) }
        it { is_expected.to include(largest_length: largest_length) }
        it { is_expected.to include(completed: completed_task_count) }
        it { is_expected.to include(pending: queue_length) }
        it { is_expected.to include(active: scheduled_task_count - completed_task_count - queue_length) }
      end
    end

    it_behaves_like 'an executor collection'

    describe 'the default collection' do
      let(:collection) { ExecutorCollection }

      it_behaves_like 'an executor collection'
    end

  end
end
