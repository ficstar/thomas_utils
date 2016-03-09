module ThomasUtils
  class ConstantVar < Struct.new(:time, :value, :error)

    def add_observer(observer = nil, func = :update, &block)
      if block
        observer = block
        func = :call
      end
      observer.public_send(func, time, value, error)
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
