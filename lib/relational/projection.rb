module Relational
  class Projection
    attr_reader :tuple, :attributes

    def initialize(tuple, attributes)
      @tuple = tuple
      @attributes = attributes

      attributes.each do |attr|
        define_singleton_method attr do
          @tuple[attr]
        end
      end
    end

    def [](key)
      @tuple[key] if attributes.include?(key)
    end

    def to_proc
      lambda do |key|
        self[key]
      end
    end

    def to_h
      attributes.reduce({}) do |h, attr|
        h.merge(attr => tuple[attr])
      end
    end

    def values
      attributes.map(&tuple)
    end
    alias to_a values

    def transform_keys
      if block_given?
        Projection.new(tuple.transform_keys(&Proc.new), attributes.map(&Proc.new))
      else
        raise 'A block is required to transform keys'
      end
    end
  end
end