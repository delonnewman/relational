module Relational
  class Relation
    include Meta
    include Enumerable
    include Relational

    attr_reader :header, :body, :meta

    def self.from(data, opts = {})
      if data.is_a?(Relation)
        if opts[:meta]
          data.with_meta(opts[:meta])
        else
          data
        end
      else
        new(data.first.keys, data, opts[:meta])
      end
    end

    def initialize(header, body, meta = {})
      @header = Set.new(header)
      @body = Set.new(body.reject(&:blank?)) if body
      @meta = meta
    end

    def each
      if block_given?
        body.each(&Proc.new)
      else
        body
      end
    end

    def with_meta(meta)
      new(header, body, meta)
    end
    
    def write(io, writer, opts = {})
      io.write(writer.call(self, opts))
    end

    def to(file, opts = {})
      ext = File.extname(file)
      format = opts.fetch(:format, ext.slice(1, ext.length))
      write(File.new(file, 'w'), writer(format), opts)
    end
    
    def as(format, opts = {})
      writer(format).call(self, opts)
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
