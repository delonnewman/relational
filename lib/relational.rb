require 'set'
require 'date'

require_relative 'relational/version'
require_relative 'relational/meta'
require_relative 'relational/relation'
require_relative 'relational/row'
require_relative 'relational/projection'
require_relative 'relational/joined_relation'
require_relative 'relational/united_relation'
require_relative 'relational/complementary_relation'
require_relative 'relational/intersected_relation'
require_relative 'relational/projected_relation'
require_relative 'relational/selected_relation'
require_relative 'relational/renamed_relation'
require_relative 'relational/predicates'
require_relative 'relational/typed_relation'
require_relative 'relational/adapter'

Dir["#{__dir__}/relational/type/*.rb"].entries.each(&method(:load))
Dir["#{__dir__}/relational/reader/*.rb"].entries.each(&method(:load))
Dir["#{__dir__}/relational/writer/*.rb"].entries.each(&method(:load))
Dir["#{__dir__}/relational/adapter/*.rb"].entries.each(&method(:load))

module Relational
  def select(*attributes)
    ProjectedRelation.new(self, Set.new(attributes))
  end

  def join(relation)
    JoinedRelation.new(self, relation)
  end
  alias * join

  # TODO: add Array and Hash Predicates
  def where(predicate = nil, &blk)
    predicate = blk if blk
    SelectedRelation.new(self, predicate)
  end

  def rename(renamings)
    RenamedRelation.new(self, renamings)
  end

  # TODO: check types for TypedRelation
  def union_compatible?(other)
    header == other.header
  end

  # TODO: Add union (|,+), intersection (&), cartiesian-product (*), difference (-)
  def union(other)
    if union_compatible?(other)
      UnitedRelation.new(self, other)
    else
      raise 'Cannot create a union with the given relation'
    end
  end
  alias + union
  alias | union

  def difference(other)
    ComplementaryRelation.new(self, other)
  end
  alias - difference

  def intersection(other)
    if union_compatible?(other)
      IntersectedRelation.new(self, other)
    else
      raise 'Connot create a intersection with the given relation'
    end
  end
  alias & intersection

  # Aggregate functions

  # Returns a set of the non-nil values of an attribute
  def column(attr)
    @column ||= Set.new(body.map(&attr.to_sym).reject(&:nil?))
  end
  alias pluck column

  def transform_column(attr)
    if block_given?
      body_ = body.lazy.map do |row|
        h = row.to_h
        Row[h.merge(attr => yield(h[attr]))]
      end
      Relation.new(header, body_)
    else
      raise 'A block is required'
    end
  end
  alias for transform_column

  # Returns the sum of the values of an attribute
  def sum(attr)
    col = column(attr)
    if col.empty?
      0
    else
      col.reduce(&:+)
    end
  end
  alias total sum

  # Returns the maximum value of an attribute
  def max(attr)
    column(attr).max
  end

  # Returns the minimum value of an attribute
  def min(attr)
    column(attr).min
  end

  # Returns the number of non-nil values of an attribute
  def count(attr = nil)
    if attr.nil?
      super()
    else
      column(attr).count
    end
  end

  # Returns the mean value of an attribute
  def mean(attr)
    n = count(attr)
    if n.zero?
      0
    else
      sum(attr) / n
    end
  end
  alias average mean

  # TODO: Implement GroupedRelation
  # see: https://www.quicksort.co.uk/DeeDoc.html#grouping-and-ungrouping-group-ungroup
  def group_by(*attrs)
    if block_given?
      body.group_by(&Proc.new)
    else
      attr = attrs.first or raise 'At least one attribute is required'
      if attrs.length == 1
        body.group_by(&attr.to_sym)
      else
        h = body.group_by do |x|
          val = x.send(attr)
          attrs.drop(1).each do |attr|
            val = val.send(attr)
          end
          val
        end
      end
    end
  end

  def sort_by(*attrs)
    if block_given?
      Relation.new(header, body.sort_by(&Proc.new))
    else
      raise 'At least one attribute is required' if attrs.length < 1
      Relation.new(header, body.sort { |a, b| a.compare(b, attrs) })
    end
  end

  def sort
    if block_given?
      Relation.new(header, body.sort(&Proc.new))
    else
      Relation.new(header, body.sort)
    end
  end

  module FromMethod
    def from(data, opts = {})
      Adapter.constants.each do |const|
        adapter = Adapter.const_get(const)
        next unless adapter.respond_to?(:dispatch?)
        data = if adapter.dispatch?(data)
                 adapter.from(data, opts)
               else
                 data
               end
      end

      if opts[:schema]
        TypedRelation.from(data, opts)
      else
        Relation.from(data, opts)
      end
    end
  end
  extend FromMethod
end

class RelationalDSL
  include Relational::FromMethod
end

def relational
  RelationalDSL.new.instance_eval(&Proc.new)
end
