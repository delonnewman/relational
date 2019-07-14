module Relational
  module Type
    class DateType
      include Predicates

      def self.coercible?(value)
        date_like? value
      end

      def self.convert(v)
        if date?(v)
          v
        elsif integer?(v)
          Time.at(v).to_date
        elsif datetime?(v) or time?(v)
          v.to_date
        elsif date_like?(v)
          if v =~ /(\d{1,2})\/(\d{1,2})\/(\d\d\d\d)/
            Date.new($3.to_i, $1.to_i, $2.to_i)
          elsif v =~ /(\d{1,2})\/(\d{1,2})\/(\d\d)/
            Date.strptime(v, '%m/%d/%y')
          else
            Date.parse(v)
          end
        else
          nil
        end
      end
    end
  end
end
