module Relational
  class UnitedRelation < Relation
    attr_reader :first, :second
  
    def initialize(first, second)
      super(first.header, nil) # load body lazily
      @first = first
      @second = second
    end
  
    def body
      (@first.body + @second.body).to_set
    end
  end
end
