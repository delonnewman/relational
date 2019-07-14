module Relational
  class TypedRelation < Relation
    include Predicates
    include Relational

    attr_reader :schema

    def self.from(data, opts = {})
      schema = opts[:schema] or raise ArgumentError, 'schema is required'
      rel = if data.is_a?(Relation)
              new(schema, data.body, opts[:meta])
            else
              new(schema, data, opts[:meta])
            end
      rel.validate!
      rel
    end

    def initialize(schema, body, meta = {})
      @schema = schema
      super(schema.keys, body, meta)
    end

    def validate!
      @body.each(&method(:validate_tuple!))
      true
    end

    def body
      @converted_body ||= @body.lazy.map do |tuple|
        pairs = schema.map do |(attr, type)|
          val = tuple[attr]
          val_ = if val.nil?
                   val
                 else
                   type_class(type).convert(val) or raise ConversionError, "There was an error converting #{val.inspect} to #{type.inspect}"
                 end
          [attr, val_]
        end
        Row[pairs]
      end
    end

    class ConversionError < Exception; end
    class ValidationError < Exception; end

    private

    def type_class_name(type)
      "#{type.capitalize}Type"
    end

    def type_class(type)
      Relational::Type.const_get(type_class_name(type))
    end

    def validate_tuple!(tuple)
      schema.each do |(attr, type)|
        val = tuple[attr]
        unless val.nil? or type_class(type).coercible?(val)
          raise ValidationError, "#{val.inspect} is not a valid #{type.inspect}"
        end
      end
      true
    end
  end
end
