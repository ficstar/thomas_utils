module ThomasUtils
  class ConstantVar < Struct.new(:time, :value, :error)

    def add_observer(observer = nil, func = :update, &block)
      if block
        observer = block
        func = :call
      end

      observer.public_send(func, time, value, error)
    end

  end
end
