module Relational
  module Type
    class IntegerType
      extend Predicates

      def self.coercible?(value)
        integer_like? value
      end

      def self.convert(v)
        if integer?(v)
          v
        else
          v.to_i
        end
      end
    end
  end
end