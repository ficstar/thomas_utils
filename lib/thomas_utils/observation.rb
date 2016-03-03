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

  end
end
