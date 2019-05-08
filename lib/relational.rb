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

Dir["#{__dir__}/relational/reader/*.rb"].entries.each(&method(:load))
Dir["#{__dir__}/relational/writer/*.rb"].entries.each(&method(:load))
Dir["#{__dir__}/relational/adapter/*.rb"].entries.each(&method(:load))

module Relational
  def project(*attributes)
    ProjectedRelation.new(self, Set.new(attributes))
  end

  def join(relation)
    JoinedRelation.new(self, relation)
  end

  def select(predicate)
    SelectedRelation.new(self, predicate)
  end

  def rename(renamings)
    RenamedRelation.new(self, renamings)
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
  extend Relational::FromMethod
end

def relational
  Class.new(RelationalDSL, &Proc.new)
end
