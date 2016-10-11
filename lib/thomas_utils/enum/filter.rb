module ThomasUtils
  module Enum
    class Filter
      include Enumerable
      include EnumerableModifier

      def initialize(enum, filter)
        @enum = enum
        @filter = filter
      end

      def each
        return self unless block_given?

        enum.each do |*_, value|
          yield value if filter[value]
        end
      end

      def ==(rhs)
        rhs.is_a?(Filter) &&
            rhs.filter == filter &&
            rhs.enum == enum
      end

      protected

      attr_reader :enum, :filter

      private

      def new_instance(enum)
        Filter.new(enum, @filter)
      end

    end
  end
end
