class Mutex
  def synchronize_unless_owned(&block)
    owned? ? yield : synchronize(&block)
  end
end
