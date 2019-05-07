require 'set'
require 'date'

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
