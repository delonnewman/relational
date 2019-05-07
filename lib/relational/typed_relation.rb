module Relational
  class TypedRelation < Relation
    include Predicates
    include Relational

    TYPES = Set[
      :string,
      :boolean,
      :integer,
      :float,
      :rational,
      :date,
      :datetime,
      :time
    ]

    boolean_converter = lambda do |v|
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

    integer_converter = lambda do |v|
      if integer?(v)
        v
      else
        v.to_i
      end
    end

    float_converter = lambda do |v|
      if float?(v)
        v
      else
        v.to_f
      end
    end

    rational_converter = lambda do |v|
      if rational?(v)
        v
      else
        v.to_r
      end
    end

    date_converter = lambda do |v|
      if date?(v)
        v
      elsif integer?(v)
        Time.at(v).to_date
      elsif datetime?(v) or time?(v)
        v.to_date
      elsif date_like?(v)
        Date.parse(v)
      else
        nil
      end
    end

    datetime_converter = lambda do |v|
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

    time_converter = lambda do |v|
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

    TYPE_CONVERTERS = {
        :string   => :to_s.to_proc,
        :boolean  => boolean_converter,
        :integer  => integer_converter,
        :float    => float_converter,
        :rational => rational_converter,
        :date     => date_converter,
        :datetime => datetime_converter,
        :time     => time_converter
    }

    TYPE_VALIDATORS = {
        :string   => method(:string_like?),
        :boolean  => method(:boolean_like?),
        :integer  => method(:integer_like?),
        :float    => method(:float_like?),
        :rational => method(:rational?),
        :date     => method(:date_like?),
        :datetime => method(:datetime_like?),
        :time     => method(:time?)
    }

    attr_reader :schema

    def self.from(schema, data)
      rel = if data.is_a?(Relation)
              new(schema, data.body)
            else
              new(schema, data)
            end
      rel.validate!
      rel
    end

    def initialize(schema, body)
      @schema = schema
      super(schema.keys, body)
    end

    def validate!
      @body.each(&method(:validate_tuple!))
      true
    end

    def body
      @converted_body ||= @body.lazy.map do |tuple|
        pairs = schema.map do |(attr, type)|
          val = tuple[attr]
          val_ = TYPE_CONVERTERS[type].call(val) or raise ConversionError, "There was an error converting #{val.inspect} to #{type.inspect}"
          [attr, val_]
        end
        Tuple[pairs]
      end
    end

    class ConversionError < Exception; end
    class ValidationError < Exception; end

    private

    def validate_tuple!(tuple)
      schema.each do |(attr, type)|
        val = tuple[attr]
        unless TYPE_VALIDATORS[type].call(val)
          raise ValidationError, "#{val.inspect} is not a valid #{type.inspect}"
        end
      end
      true
    end
  end
end