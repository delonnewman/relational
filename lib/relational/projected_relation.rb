module Relational
  class ProjectedRelation < Relation

    attr_reader :relation

    def initialize(relation, attributes)
      @relation = relation
      super(attributes, nil) # load body lazily
    end

    def body
      relation.body.lazy.map do |tuple|
        Projection.new(tuple.to_h, header)
      end
    end
  end
end