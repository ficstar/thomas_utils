module ThomasUtils
  module Enum
    class Mapping
      include Enumerable
      include EnumerableModifier
      include Indexing

      def initialize(enum, callback)
        @enum = enum
        @callback = callback
      end

      def each
        return self unless block_given?

        @enum.each do |value|
          yield @callback[value]
        end
      end

      alias :get :to_a

      protected

      attr_reader :enum, :callback

      private

      def new_instance(enum)
        Mapping.new(enum, @callback)
      end

    end
  end
end
