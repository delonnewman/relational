require 'csv'

module Relational
  module Adapter
    class Csv
      class << self
        def dispatch?(data)
          data.is_a?(CSV::Table)
        end

        def self.from(data)
          if data.is_a?(CSV::Table)
            Relational::Relation.new(data.first.to_h.keys, data)
          else
            raise Adapter::Error, "Don't know how to import data from #{data.inspect}"
          end
        end
      end
    end
  end
end