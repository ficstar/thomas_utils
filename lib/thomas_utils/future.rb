module ThomasUtils
  class Future < Observation
    DEFAULT_EXECUTOR = ::Concurrent::CachedThreadPool.new
    IMMEDIATE_EXECUTOR = ::Concurrent::ImmediateExecutor.new

    def self.value(value)
      Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.value(value))
    end

    def self.immediate(&block)
      start_time = Time.now
      observable = begin
        ConstantVar.value(block.call)
      rescue Exception => error
        ConstantVar.error(error)
      end
      Observation.new(IMMEDIATE_EXECUTOR, observable, start_time)
    end

    def self.none
      Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.none)
    end

    def self.error(error)
      Observation.new(IMMEDIATE_EXECUTOR, ConstantVar.error(error))
    end

    def self.all(observations)
      initialized_at = observations.map(&:initialized_at).min
      observable = Concurrent::IVar.new
      left = observations.count
      buffer = [nil] * left
      mutex = Mutex.new
      observations.each_with_index do |observation, index|
        observation.on_complete do |value, error|
          if error
            observable.fail(error)
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

    def initialize(options = {}, &block)
      executor = options.fetch(:executor) { DEFAULT_EXECUTOR }
      observable = Concurrent::Future.execute(executor: executor, &block)
      super(executor, observable)
    end

  end
end

