require 'set'
require 'date'

require 'relational/version'
require 'relational/meta'
require 'relational/relation'
require 'relational/projection'
require 'relational/joined_relation'
require 'relational/projected_relation'
require 'relational/selected_relation'
require 'relational/renamed_relation'
require 'relational/predicates'
require 'relational/typed_relation'
require 'relational/adapter'

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

  # TODO: add Array and Hash Predicates
  def where(predicate = nil, &blk)
    predicate = blk if blk
    SelectedRelation.new(self, predicate)
  end

  def rename(renamings)
    RenamedRelation.new(self, renamings)
  end

  # TODO: Add union (|,+), intersection (&), cartiesian-product (*), difference (-)

  # Aggregate functions

  # Returns a set of the non-nil values of an attribute
  def column(attr)
    @column ||= Set.new(body.map(&attr.to_sym).reject(&:nil?))
  end

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
  def count(attr)
    column(attr).count
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
      attr = attrs.first or raise 'At least one attribute is required'
      if attrs.length == 1
        Relation.new(header, body.sort_by(&attr.to_sym))
      else
        a = body.sort_by do |x|
          val = x.send(attr)
          attrs.drop(1).each do |attr|
            val = val.send(attr)
          end
          val
        end
        Relation.new(header, a)
      end
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
