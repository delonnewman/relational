module Relational
  module Type
    class FloatType
      extend Predicates

      def self.coercible?(value)
        float_like? value
      end

      def self.convert(v)
        if float?(v)
          v
        else
          v.to_f
        end
      end
    end
  end
end