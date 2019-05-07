module Relational
  module Serializer
    class Csv
      def call(relation)
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