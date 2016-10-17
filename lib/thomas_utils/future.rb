module ThomasUtils
  class Future < Observation
    DEFAULT_EXECUTOR = ::Concurrent::CachedThreadPool.new
    IMMEDIATE_EXECUTOR = ::Concurrent::ImmediateExecutor.new

    class << self
      def value(value)
        Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.value(value))
      end

      def immediate(&block)
        start_time = Time.now
        observable = begin
          ConstantVar.value(block.call)
        rescue Exception => error
          ConstantVar.error(error)
        end
        Observation.new(IMMEDIATE_EXECUTOR, observable, start_time)
      end

      def none
        Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.none)
      end

      def error(error)
        Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.error(error))
      end

      def all(observations)
        return value([]) if observations.none?

        initialized_at = observations.map(&:initialized_at).min
        observable = Concurrent::IVar.new
        left = observations.count
        buffer = [nil] * left
        mutex = Mutex.new
        observations.each_with_index do |observation, index|
          observation.on_complete do |value, error|
            if error
              mutex.synchronize do
                observable.fail(error) unless observable.complete?
              end
            else
              buffer[index] = value
              done = false
              mutex.synchronize do
                left -= 1
                done = !!left.zero?
              end
              observable.set(buffer) if done
            end
          end
        end
        Observation.new(DEFAULT_EXECUTOR, observable, initialized_at)
      end

      def successive(options = {}, &block)
        new(options, &block).then { |result| result }
      end
    end

    def initialize(options = {}, &block)
      executor = options.fetch(:executor) { DEFAULT_EXECUTOR }
      executor = ExecutorCollection[executor] unless executor.is_a?(Concurrent::ExecutorService)
      observable = Concurrent::Future.execute(executor: executor, &block)
      super(executor, observable)
    end

  end
end

