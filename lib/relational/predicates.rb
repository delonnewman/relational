module Relational
  module Predicates
    def self.included(base)
      base.extend(self)
    end

    INTEGER_REGEX = /\A[+-]?\d+\z/
    DECIMAL_REGEX = /\A[+-]?\d+\.\d+\z/
    NUMBER_REGEX  = /\A[+-]?\d+((\.\d+)?(e(\-|\+)\d+)?)\z/

    #
    # Type Predicates
    # ===============

    def string?(value)
      value.is_a?(String)
    end

    def string_like?(value)
      string?(value) or value.respond_to?(:to_s)
    end

    def boolean?(value)
      value == true || value == false
    end

    def boolean_like?(value)
      boolean?(value) or
          (string?(value) and (value == 'true' or value == 'false')) or
          (integer?(value) and (value == 0 or value == 1))
    end

    def integer?(value)
      value.is_a?(Integer)
    end

    def integer_like?(value)
      integer?(value) or (string?(value) and INTEGER_REGEX =~ value)
    end

    def numeric?(value)
      value.is_a?(Numeric)
    end

    def number_like?(value)
      numeric?(value) or (string?(value) and NUMBER_REGEX =~ value)
    end

    def float?(value)
      value.is_a?(Float)
    end

    def float_like?(value)
      float?(value) or (string?(value) and DECIMAL_REGEX =~ value)
    end

    def rational?(value)
      value.is_a?(Rational)
    end

    def date?(value)
      value.is_a?(Date)
    end

    def date_like?(value)
      date?(value) or integer?(value) or begin
        if value =~ /\d{1,2}\/\d{1,2}\/(\d\d)|(\d\d\d\d)/
          true
        else
          Date.parse(value)
          true
        end
      rescue ArgumentError
        false
      end
    end

    def datetime?(value)
      value.is_a?(DateTime)
    end

    def datetime_like?(value)
      datetime?(value) or integer?(value) or begin
        DateTime.parse(value)
        true
      rescue ArgumentError
        false
      end
    end

    def time?(value)
      value.is_a?(Time)
    end

    def currency?(value)
      numeric?(value) or value =~ /\$?\d+\.\d\d/
    end
  end
end
