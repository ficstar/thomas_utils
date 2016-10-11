module ThomasUtils
  module Enum
    module EnumerableModifier

      def respond_to?(method, include_all = false)
        super(method, include_all) || enum.respond_to?(method, include_all)
      end

      def method_missing(method, *args, &block)
        child_enum = enum.public_send(method, *args, &block)
        new_instance(child_enum)
      end

      private

      alias :klass :class

    end
  end
end
