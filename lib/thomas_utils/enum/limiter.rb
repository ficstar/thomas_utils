module ThomasUtils
  module Enum
    class Limiter
      include Enumerable

      def initialize(enum, limit)
        @enum = enum
        @limit = limit
      end

      def each
        return self unless block_given?

        @enum.each.with_index do |value, index|
          break if index >= @limit
          yield value
        end
      end

      alias :get :to_a

      def respond_to?(method, include_all = false)
        super(method, include_all) || enum.respond_to?(method, include_all)
      end

      def method_missing(method, *args, &block)
        child_enum = enum.public_send(method, *args, &block)
        klass.new(child_enum, limit)
      end

      def ==(rhs)
        rhs.is_a?(klass) &&
            enum == rhs.enum &&
            limit == rhs.limit
      end

      protected

      attr_reader :enum, :limit
      alias :klass :class

    end
  end
end
