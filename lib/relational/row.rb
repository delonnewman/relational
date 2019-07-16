module Relational
  class Row
    def self.[](*args)
      return args.first if args.length == 1 and args.first.is_a?(Row)
      h = if args.length == 1 and args.first.is_a?(Hash)
            args.first
          else
            Hash[*args]
          end
      new(h)
    end

    def initialize(rep)
      @rep = rep

      raise "A row tuple cannot be nil" if rep.nil?

      keys.each do |attr|
        define_singleton_method attr do
          @rep[attr]
        end
      end
    end

    def to_h
      @rep
    end

    def blank?
      @blank ||= to_h.values.all? { |v| v.nil? or v == '' }
    end

    def [](key)
      @rep.fetch(key, nil)
    end

    def <=>(other)
      compare(other, keys)
    end

    def compare(other, attrs)
      if !other.is_a?(Row)
        raise "Don't know how to compare a row to #{other.inspect}:#{other.class}"
      elsif length != other.length
        raise "Don't know how to compare two rows of a different size"
      else
        attrs.reduce(0) do |cmp, attr|
          if cmp == 1 or cmp == -1
            cmp
          else
            nil_safe_compare(self[attr], other[attr])
          end
        end
      end
    end

    def ==(other)
      if !other.is_a?(Row)
        false
      else
        to_h == other.to_h
      end
    end

    def nil_safe_compare(a, b)
      if a == b
        0
      elsif a.nil?
        -1
      elsif b.nil?
        1
      else
        a <=> b
      end
    end

    def to_proc
      lambda do |key|
        self[key]
      end
    end

    def values
      @rep.values
    end
    alias to_a values

    def keys
      @rep.keys
    end

    def length
      @rep.length
    end

    def transform_keys
      if block_given?
        Row.new(@rep.transform_keys(&Proc.new))
      else
        raise 'A block is required to transform keys'
      end
    end
  end
end
