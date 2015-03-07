class MockFuture
  VALUE = 'value'

  def initialize(erroneous = false)
    @erroneous = erroneous
  end

  def join

  end

  def on_success
    yield get unless @erroneous
  end

  def on_failure
    yield VALUE if @erroneous
  end

  def get
    @erroneous ? (raise VALUE) : VALUE
  end
end