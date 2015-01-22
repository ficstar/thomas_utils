class FutureWrapper
  extend Forwardable

  def_delegator :@future, :join

  def initialize(future, &callback)
    @future = future
    @callback = callback
  end

  def get
    @callback.call(@future.get)
  end
end