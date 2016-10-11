module Enumerable
  def lazy_limit(limit)
    ThomasUtils::Enum::Limiter.new(self, limit)
  end

  def lazy_filter(filter = nil, &filter_block)
    filter ||= filter_block
    ThomasUtils::Enum::Filter.new(self, filter)
  end
end
