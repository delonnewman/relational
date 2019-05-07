module Relational
  class RenamedRelation < Relation
    def initialize(relation, renamings)
      @relation = relation
      @renamings = renamings
      super(header, nil) # load body lazily
    end

    def header
      @header ||= @relation.header.map { |attr| @renamings[attr] || attr }
    end

    def body
      @relation.body.lazy.map do |tuple|
        tuple.transform_keys { |attr| @renamings[attr] || attr }
      end
    end
  end
end