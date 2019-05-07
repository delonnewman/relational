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
require 'relational/writer/csv'
require 'relational/writer/json'
require 'relational/reader/csv'
require 'relational/reader/json'

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
end

class RelationalDSL
  class << self
    def from(source, opts = {})
      data = if source.is_a?(String) and File.exists?(source)
               ext = File.extname(source)
               str = IO.read(source)
               reader(ext.slice(1, ext.length)).call(str)
             elsif source.is_a?(String) and opts[:format]
               reader(opts[:format]).call(source)
             elsif source.is_a?(String)
               raise "Don't know how to read the given data. Strings should either be the name of a file that exists " \
                     "in the file system or the data format of the string should be given with the :format option."
             else
               source
             end

      data = if defined?(ActiveRecord::Base) and data.is_a?(Class) and data.is_a?(ActiveRecord::Base)
               Relational::Relation.new(data.attribute_names.map(&:to_sym), data.all)
             elsif defined?(ActiveRecord::Relation) and data.is_a?(ActiveRecord::Relation)
               Relational::Relation.new(data.attribute_names.map(&:to_sym), data)
             elsif defined?(CSV::Table) and data.is_a?(CSV::Table)
               Relational::Relation.new(data.first.to_h.keys, data)
             else
               data
             end
      
      if opts[:schema]
        Relational::TypedRelation.from(opts[:schema], data)
      else
        Relational::Relation.from(data)
      end
    end

    private

    def reader(format)
      const_name = format.capitalize
      if begin
        Relational::Reader.const_defined?(const_name);
      rescue NameError;
        false
      end
        Relational::Reader.const_get(const_name).new
      else
        raise "Don't know how to read data from #{format.inspect} format"
      end
    end
  end
end

def relational
  Class.new(RelationalDSL, &Proc.new)
end
