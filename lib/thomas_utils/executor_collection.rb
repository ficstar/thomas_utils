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

    @default_collection = new.freeze
  end
end
