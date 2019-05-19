module Relational
  module Type
    class RationalType
      extend Predicates

      def self.coercible?(value)
        numeric? value
      end

      def self.convert(v)
        if rational?(v)
          v
        else
          v.to_r
        end
      end
    end
  end
end