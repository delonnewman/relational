require 'csv'

module Relational
  module Reader
    class Csv
      def call(str, _opts)
        data = CSV.parse(str)
        headers = data.first
        data.drop(1).map do |row|
          headers.each_with_index.reduce({}) do |h, (attr, i)|
            h.merge(attr.to_sym => row[i])
          end
        end
      end
    end
  end
end