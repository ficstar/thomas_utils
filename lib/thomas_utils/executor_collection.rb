module ThomasUtils
  class ExecutorCollection
    extend Forwardable

    def_delegator :@collection, :[]

    def self.[](name)
      @default_collection[name]
    end

    def self.build(name, max_threads = nil, max_queue = nil)
      @default_collection.build(name, max_threads, max_queue)
    end

    def self.stats
      @default_collection.stats
    end

    def initialize
      @collection = {immediate: Concurrent::ImmediateExecutor.new}
    end

    def build(name, max_threads = nil, max_queue = nil)
      @collection[name] = if max_threads
                            Concurrent::ThreadPoolExecutor.new(
                                min_threads: 0,
                                max_threads: max_threads,
                                max_queue: max_queue,
                                fallback_policy: :caller_runs,
                                auto_terminate: true
                            )
                          else
                            Concurrent::CachedThreadPool.new
                          end
    end

    def stats
      @collection.inject({}) do |stats, (name, executor)|
        executor_stats = case executor
                           when Concurrent::ImmediateExecutor
                             {
                                 maximum_active_tasks: 1,
                                 maximum_queued_tasks: 0,
                                 largest_length: 1,
                                 completed: -1,
                                 pending: 0,
                                 active: -1
                             }
                           else
                             {
                                 maximum_active_tasks: executor.max_length,
                                 maximum_queued_tasks: executor.max_queue,
                                 largest_length: executor.largest_length,
                                 completed: executor.completed_task_count,
                                 pending: executor.queue_length,
                                 active: executor.scheduled_task_count - executor.completed_task_count - executor.queue_length
                             }
                         end
        stats.merge(name => executor_stats)
      end
    end

    @default_collection = new.freeze
  end
end
