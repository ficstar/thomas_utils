module Enumerable
  def lazy_limit(limit)
    ThomasUtils::Enum::Limiter.new(self, limit)
  end
end
