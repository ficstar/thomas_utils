module ThomasUtils
  module Enum
    module Indexing

      def with_index(&block)
        to_enum(:each).with_index(&block)
      end

    end
  end
end
