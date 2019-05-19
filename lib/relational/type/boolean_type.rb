module Relational
  module Type
    class BooleanType
      extend Predicates

      def self.coercible?(value)
        boolean_like? value
      end

      def self.convert(v)
        if boolean?(v)
          v
        elsif string?(v)
          if v == 'false'
            false
          elsif v == 'true'
            true
          else
            nil
          end
        elsif integer?(v)
          if v == 0
            false
          elsif v == 1
            true
          else
            nil
          end
        else
          nil
        end
      end
    end
  end
end