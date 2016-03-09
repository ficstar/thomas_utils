module ThomasUtils
  class ConstantVar < Struct.new(:time, :value, :reason)

    def self.value(value)
      new(Time.now, value, nil)
    end

    def self.error(error)
      new(Time.now, nil, error)
    end

    def value!
      raise reason if reason
      value
    end

    def add_observer(observer = nil, func = :update, &block)
      if block
        observer = block
        func = :call
      end
      observer.public_send(func, time, value, reason)
    end

    def with_observer(observer = nil, func = :update, &block)
      add_observer(observer, func, &block)
      self
    end

    def delete_observer(_)
      raise NotImplementedError
    end

    def delete_observers
      raise NotImplementedError
    end

    def count_observers
      raise NotImplementedError
    end

  end
end
