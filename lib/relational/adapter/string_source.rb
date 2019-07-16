module Relational
  module Adapter
    class StringSource
      class << self
        def dispatch?(data)
          data.is_a?(String)
        end

        def from(source, opts = {})
          if source.is_a?(String) and File.exists?(source)
            ext = File.extname(source)
            str = IO.read(source)
            reader(opts.fetch(:format, ext.slice(1, ext.length))).call(str, opts)
          elsif source.is_a?(String) and opts[:format]
            reader(opts[:format]).call(source, opts)
          elsif source.is_a?(String)
            raise "Don't know how to read the given data. Strings should either be the name of a file that exists " \
                  "in the file system or the data format of the string should be given with the :format option."
          else
            source
          end
        end

        def reader(format)
          const_name = format.capitalize
          if begin
            Reader.const_defined?(const_name);
          rescue NameError;
            false
          end
            Reader.const_get(const_name).new
          else
            raise "Don't know how to read data from #{format.inspect} format"
          end
        end
      end
    end
  end
end
