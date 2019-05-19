module Relational
  module Type
    class StringType
      def self.coercible?(value)
        value.is_a? String
      end

      def self.convert(value)
        value
      end
    end
  end
end