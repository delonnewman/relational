require 'set'
require 'date'
require 'csv'

require 'relational/version'
require 'relational/relation'
require 'relational/tuple'
require 'relational/projection'
require 'relational/joined_relation'
require 'relational/projected_relation'
require 'relational/selected_relation'
require 'relational/renamed_relation'
require 'relational/predicates'
require 'relational/typed_relation'
require 'relational/serializer'
require 'relational/deserializer'

module Relational
  def select(*attributes)
    ProjectedRelation.new(self, Set.new(attributes))
  end

  def join(relation)
    JoinedRelation.new(self, relation)
  end

  def where(predicate)
    SelectedRelation.new(self, predicate)
  end

  def rename(renamings)
    RenamedRelation.new(self, renamings)
  end
  
  class DSL
    class << self
    def from(source, opts = {})
      data = if source.is_a?(String) and File.exists?(source)
               ext = File.extname(source)
               str = IO.read(source)
               deserializer(ext.slice(1, ext.length)).call(str)
             else
               source
             end
      if opts[:schema]
        TypedRelation.from(opts[:schema], data)
      else
        Relation.from(data)
      end
    end
    
    private

    def deserializer(format)
      const_name = format.capitalize
      if begin Deserializer.const_defined?(const_name); rescue NameError; false end
        Deserializer.const_get(const_name).new
      else
        raise "Don't know how to deserialize data from #{format.inspect} format"
      end
    end
      end
  end
end

def relational
  Class.new(Relational::DSL, &Proc.new)
end
