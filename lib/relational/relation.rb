module Relational
  class Relation
    include Relational

    attr_reader :header, :body

    def self.from(data)
      header = data.first.keys
      new(header, data)
    end

    def initialize(header, body)
      @header = Set.new(header)
      @body = Set.new(body)
    end
  end
end