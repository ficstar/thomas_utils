module ThomasUtils
  module Enum
    class Combiner
      include Enumerable
      include Indexing

      def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs
      end

      def each(&block)
        return self unless block_given?

        lhs.each(&block)
        rhs.each(&block)
      end

      def respond_to?(method, include_all = false)
        super(method, include_all) || enums_respond_to?(method, include_all)
      end

      def method_missing(method, *args, &block)
        child_lhs = lhs.public_send(method, *args, &block)
        child_rhs = rhs.public_send(method, *args, &block)
        new_instance(child_lhs, child_rhs)
      end

      def ==(rhs_combiner)
        rhs_combiner.is_a?(Combiner) &&
            rhs_combiner.lhs == lhs &&
            rhs_combiner.rhs == rhs
      end

      protected

      attr_reader :lhs, :rhs

      private

      alias :klass :class

      def enums_respond_to?(method, include_all)
        lhs.respond_to?(method, include_all) &&
            rhs.respond_to?(method, include_all)
      end

      def new_instance(lhs, rhs)
        Combiner.new(lhs, rhs)
      end

    end
  end
end

