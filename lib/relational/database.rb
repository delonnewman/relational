module Relational
  # TODO: Consider adding indexing
  class Database
    def initialize
      @relations = {}
      instance_eval(&Proc.new) if block_given?
    end

    def from(name, source)
      @relations[name.to_sym] = Relational.from(source)
      self
    end

    def [](relation)
      @relations[relation]
    end
  end
end
