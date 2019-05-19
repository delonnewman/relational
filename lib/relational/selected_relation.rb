module Relational
  class SelectedRelation < Relation
    attr_reader :relation, :predicate

    def initialize(relation, predicate)
      @relation = relation
      @predicate = predicate
      super(relation.header, nil)
    end

    def body
      relation.body.lazy.select(&predicate)
    end
  end
end