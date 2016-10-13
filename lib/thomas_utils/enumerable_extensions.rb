module Enumerable
  DEFAULT_UNIQUE_BLOCK = lambda { |item| item }.freeze

  def lazy_limit(limit)
    ThomasUtils::Enum::Limiter.new(self, limit)
  end

  alias :limit :lazy_limit

  def lazy_filter(filter = nil, &filter_block)
    filter ||= filter_block
    ThomasUtils::Enum::Filter.new(self, filter)
  end

  def lazy_union(rhs)
    ThomasUtils::Enum::Combiner.new(self, rhs)
  end

  def lazy_uniq(callback = nil, &block)
    callback ||= block
    callback ||= DEFAULT_UNIQUE_BLOCK
    ThomasUtils::Enum::MakeUnique.new(self, callback)
  end
end
