module Relational
  class Relation
    include Relational

    attr_reader :header, :body

    def self.from(data)
      if defined?(ActiveRecord::Base) and data.is_a?(Class) and data.is_a?(ActiveRecord::Base)
        new(data.attribute_names.map(&:to_s), data.all)
      elsif defined?(ActiveRecord::Relation) and data.is_a?(ActiveRecord::Relation)
        new(data.attribute_names.map(&:to_s), data)
      else defined?(CSV::Table) and data.is_a?(CSV::Table)
        new(data.first.to_h.keys, data)
      end
    end

    def initialize(header, body)
      @header = Set.new(header)
      @body = Set.new(body)
    end
    
    def write(io, serializer)
      io.write(serializer.call(self))
    end

    def to(file)
      ext = File.extname(file)
      s = serializer(ext)
      write(File.new(file, 'w'), s)
    end
    
    def to_a
      body.map(&:to_h).to_a
    end
    
    private
    
    def serializer(ext)
      const_name = ext.slice(1, ext.length).capitalize
      if begin Serializer.const_defined?(const_name); rescue NameError; false end
        Serializer.const_get(const_name).new
      else
        raise "Don't know how to serialize data to #{ext.inspect} format"
      end
    end
  end
end