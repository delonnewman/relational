require 'csv'

module Relational
  module Reader
    class Csv
      def call(str, opts)
        data = CSV.parse(str)
        header = opts[:header] || (opts[:schema] && opts[:schema].keys)
        data = opts[:header] ? data : data.drop(1)
        header = data.first unless header
        body = data.map do |row|
          tuple = header.each_with_index.reduce({}) do |h, (attr, i)|
            h.merge(attr.to_sym => row[i])
          end
          Projection[tuple]
        end
        Relation.new(header, body, opts[:meta])
      end
    end
  end
end
