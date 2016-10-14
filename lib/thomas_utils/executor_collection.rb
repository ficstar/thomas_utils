module ThomasUtils
  class ExecutorCollection
    extend Forwardable

    def_delegator :@collection, :[]

    def self.[](name)
      @default_collection[name]
    end

    def self.build(name, max_threads, max_queue)
      @default_collection.build(name, max_threads, max_queue)
    end

    def self.stats
      @default_collection.stats
    end

    def initialize
      @collection = {}
    end

    def build(name, max_threads, max_queue)
      @collection[name] = Concurrent::ThreadPoolExecutor.new(
          min_threads: 0,
          max_threads: max_threads,
          max_queue: max_queue,
          fallback_policy: :caller_runs,
          auto_terminate: true
      )
    end

    def stats
      @collection.inject({}) do |stats, (name, executor)|
        executor_stats = {
            maximum_active_tasks: executor.max_length,
            maximum_queued_tasks: executor.max_queue,
            largest_length: executor.largest_length,
            completed: executor.completed_task_count,
            pending: executor.queue_length,
            active: executor.scheduled_task_count - executor.completed_task_count - executor.queue_length
        }
        stats.merge(name => executor_stats)
      end
    end

    @default_collection = new.freeze
  end
end
