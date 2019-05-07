module Relational
  # Performs a natural join on the two relations
  class JoinedRelation < Relation
    attr_reader :relation, :other

    def initialize(relation, other)
      @relation = relation
      @other = other
      super(relation.header | other.header, nil)
    end

    def common_attributes
      @common_attributes ||= (relation.header & other.header)
    end

    def body
      relation.body.lazy.flat_map do |t1|
        other.body.lazy.flat_map do |t2|
          if common_attributes.empty?
            [t1.merge(t2)]
          else
            common_attributes.map do |attr|
              if t1[attr] == t2[attr]
                t1.merge(t2)
              else
                nil
              end
            end.reject(&:nil?)
          end
        end
      end
    end
  end
end