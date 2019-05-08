require 'csv'

module Relational
  module Writer
    class Csv
      def call(relation, _opts)
        CSV.generate do |csv|
          csv << relation.header
          relation.body.each do |tuple|
            csv << tuple.to_a
          end
        end
      end
    end
  end
end