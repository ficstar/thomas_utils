module ThomasUtils
  class Observation
    extend Forwardable

    def_delegator :@observable, :value!, :get
    attr_reader :initialized_at, :resolved_at

    def initialize(executor, observable, initialized_at = Time.now)
      @executor = executor
      @observable = observable
      @initialized_at = initialized_at

      @observable.add_observer { |resolved_at, _, _| @resolved_at = resolved_at }
    end

    def on_success
      @observable.add_observer do |_, value, error|
        @executor.post do
          yield value unless error
        end
      end
      self
    end

    def on_failure
      @observable.add_observer do |_, _, error|
        @executor.post do
          yield error if error
        end
      end
      self
    end

    def on_complete
      @observable.add_observer do |_, value, error|
        @executor.post do
          yield value, error
        end
      end
      self
    end

    def join
      @observable.value
      self
    end

    def then(&block)
      successive(:on_complete_then, &block)
    end

    def none_fallback
      self.then do |result|
        result || yield
      end
    end

    def fallback(&block)
      successive(:on_complete_fallback, &block)
    end

    def ensure(&block)
      successive(:on_complete_ensure, &block)
    end

    def on_success_ensure(&block)
      self.then do |result|
        child_result = block.call(result)
        if result_is_observation?(child_result)
          child_result.then { result }
        else
          result
        end
      end
    end

    def on_failure_ensure(&block)
      self.fallback do |error|
        result = block.call(error)
        error_observation = Observation.new(@executor, ConstantVar.error(error))
        if result_is_observation?(result)
          result.then { error_observation }
        else
          error_observation
        end
      end
    end

    private

    def successive(method, &block)
      observable = Concurrent::IVar.new
      send(method, observable, &block)
      Observation.new(@executor, observable)
    end

    def on_complete_then(observable, &block)
      on_complete do |value, error|
        if error
          observable.fail(error)
        else
          on_success_then(observable, value, &block)
        end
      end
    end

    def on_complete_fallback(observable, &block)
      on_complete do |value, error|
        if error
          on_failure_fallback(observable, error, &block)
        else
          observable.set(value)
        end
      end
    end

    def on_success_then(observable, value)
      result = yield value
      if result_is_observation?(result)
        result.on_complete do |child_result, child_error|
          ensure_then(child_error, observable, child_result)
        end
      else
        observable.set(result)
      end
    rescue Exception => error
      observable.fail(error)
    end

    alias :on_failure_fallback :on_success_then

    def on_complete_ensure(observable)
      on_complete do |value, error|
        begin
          result = yield value, error
          if result_is_observation?(result)
            ensure_complete_then(error, observable, result, value)
          else
            ensure_then(error, observable, value)
          end
        rescue Exception => child_error
          observable.fail(child_error)
        end
      end
    end

    def ensure_complete_then(error, observable, result, value)
      result.on_complete do |_, child_error|
        if child_error
          observable.fail(child_error)
        elsif error
          observable.fail(error)
        else
          observable.set(value)
        end
      end
    end

    def ensure_then(error, observable, value)
      if error
        observable.fail(error)
      else
        observable.set(value)
      end
    end

    def result_is_observation?(result)
      result.respond_to?(:on_complete) && result.respond_to?(:then)
    end
  end
end
