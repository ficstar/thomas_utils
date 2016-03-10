module ThomasUtils
  class Observation
    extend Forwardable

    def_delegator :@observable, :value!, :get

    def initialize(executor, observable)
      @executor = executor
      @observable = observable
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

    def fallback(&block)
      successive(:on_complete_fallback, &block)
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
      if result.is_a?(Observation)
        result.on_complete do |child_result, child_error|
          if child_error
            observable.fail(child_error)
          else
            observable.set(child_result)
          end
        end
      else
        observable.set(result)
      end
    rescue => error
      observable.fail(error)
    end

    alias :on_failure_fallback :on_success_then

  end
end
