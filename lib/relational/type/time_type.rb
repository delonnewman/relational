module Relational
  module Type
    class TimeType
      extend Predicates

      def self.coercible?(value)
        time? value
      end

      def self.convert(v)
        if time?(v)
        elsif integer?(v)
          Time.at(v)
        elsif datetime?(v) or date?(v)
          v.to_time
        elsif datetime_like?(v)
          DateTime.parse(v).to_time
        else
          nil
        end
      end
    end
  end
end