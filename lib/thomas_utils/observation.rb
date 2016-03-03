module ThomasUtils
  class Observation

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

  end
end
