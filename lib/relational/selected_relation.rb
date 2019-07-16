module Relational
  class SelectedRelation < Relation
    attr_reader :relation, :predicate

    def initialize(relation, predicate)
      @relation = relation
      @predicate = predicate
      super(relation.header, nil)
    end

    def body
      case predicate
      when Hash
        relation.body.lazy.select do |row|
          predicate.reduce(true) do |result, (attr, value)|
            result and value === row[attr]
          end
        end
      else
        relation.body.lazy.select(&predicate)
      end
    end
  end
end
