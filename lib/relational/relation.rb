module Relational
  class Relation
    include Relational

    attr_reader :header, :body

    def self.from(data)
      if data.is_a?(Relation)
        data
      else
        new(data.first.keys, data)
      end
    end

    def initialize(header, body)
      @header = Set.new(header)
      @body = Set.new(body)
    end
    
    def write(io, writer)
      io.write(writer.call(self))
    end

    def to(file)
      ext = File.extname(file)
      format = ext.slice(1, ext.length)
      write(File.new(file, 'w'), writer(format))
    end
    
    def as(format)
      writer(format).call(self)
    end
    
    def to_a
      body.map(&:to_h).to_a
    end
    
    private
    
    def writer(format)
      const_name = format.capitalize
      if begin Writer.const_defined?(const_name); rescue NameError; false end
        Writer.const_get(const_name).new
      else
        raise "Don't know how to serialize data to #{format.inspect} format"
      end
    end
  end
end