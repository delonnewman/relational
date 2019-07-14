module Relational
  module Type
    class CurrencyType
      include Predicates

      CURRENCY_REGEX = /\A(\-?\$?\d+(\.\d+)?)|(\$?\(\d+(\.\d+)?\))\z/.freeze

      def self.coercible?(value)
        numeric?(value) or string?(value) and not (value =~ CURRENCY_REGEX).nil?
      end

      def self.convert(value)
        if numeric? value
          new(value.to_r)
        else
          if value =~ /\$?\(\d+\.\d+\)/
            new(value.gsub(/[\(\)\$]/, '').to_r * -1)
          else
            new(value.tr('$', '').to_r)
          end
        end
      end

      def initialize(rep)
        @rep = rep
      end

      def to_r
        @rep
      end

      def <=>(other)
        if (gt = self > other).nil? and (lt = self < other).nil?
          nil
        elsif gt
          1
        elsif lt
          -1
        else
          0
        end
      end

      def >(other)
        case other
        when Rational
          to_r > other
        when Float
          to_f > other
        when Integer
          to_i > other
        when CurrencyType
          to_r > other.to_r
        else
          if other.nil?
            true
          else
            nil
          end
        end
      end

      def <(other)
        case other
        when Rational
          to_r < other
        when Float
          to_f < other
        when Integer
          to_i < other
        when CurrencyType
          to_r < other.to_r
        else
          if other.nil?
            false
          else
            nil
          end
        end
      end

      def ==(other)
        case other
        when Rational
          to_r == other
        when Float
          to_f == other
        when Integer
          to_i == other
        when CurrencyType
          to_r == other.to_r
        else
          false
        end
      end

      def to_f
        @rep.to_f
      end

      def +(other)
        if other.is_a? CurrencyType
          self.class.new(@rep + other.to_r)
        elsif numeric? other
          @rep + other
        else
          raise TypeError, "Don't know how to add a #{self.class} to a #{other.class}"
        end
      end

      def -(other)
        if other.is_a? CurrencyType
          self.class.new(@rep - other.to_r)
        elsif numeric? other
          @rep - other
        else
          raise TypeError, "Don't know how to subtract a #{other.class} from a #{self.class}"
        end
      end

      def *(other)
        if other.is_a? CurrencyType
          @rep * other.to_r
        elsif numeric? other
          @rep * other
        else
          raise TypeError, "Don't know how to multiply a #{self.class} to a #{other.class}"
        end
      end

      def /(other)
        if other.is_a? CurrencyType
          @rep / other.to_r
        elsif numeric? other
          @rep / other
        else
          raise TypeError, "Don't know how to divide a #{self.class} by a #{other.class}"
        end
      end

      def round(*args)
        @rep.round(*args)
      end

      def to_i
        round
      end

      def ceil(*args)
        @rep.ceil(*args)
      end

      def floor(*args)
        @rep.floor(*args)
      end

      def to_s
        if @rep < 0
          "$(#{to_f.abs})"
        else
          "$#{to_f}"
        end
      end
    end
  end
end
