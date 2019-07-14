module Relational
  module Type
    class DateTimeType
      extend Predicates

      def self.coercible?(value)
        datetime_like? value
      end

      def self.convert(v)
        if datetime?(v)
          v
        elsif integer?(v)
          Time.at(v).to_datetime
        elsif date?(v) or time?(v)
          v.to_datetime
        elsif datetime_like?(v)
          DateTime.parse(v)
        else
          nil
        end
      end
    end
  end
end
