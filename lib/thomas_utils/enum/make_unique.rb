module ThomasUtils
  module Enum
    class MakeUnique
      include Enumerable
      include EnumerableModifier
      include Indexing

      def initialize(enum, callback)
        @enum = enum
        @callback = callback
      end

      def each
        return self unless block_given?

        seen = Set.new
        enum.each do |item|
          key = callback[item]
          unless seen.include?(key)
            seen << key
            yield item
          end
        end
      end

      private

      attr_reader :enum, :callback

      def new_instance(enum)
        MakeUnique.new(enum, callback)
      end

    end
  end
end
