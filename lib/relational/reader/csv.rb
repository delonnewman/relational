require 'csv'

module Relational
  module Reader
    # Options:
    #   - header (a collection of header symbols)
    #   - schema (a hash of header symbols and types)
    class Csv
      def call(str, opts)
        data   = CSV.parse(str)
        header = opts[:header] || (opts[:schema] && opts[:schema].keys)
        header = data.first.map(&:to_sym) unless header
        data   = opts[:header] ? data : data.drop(1)
        body = data.map do |row|
          tuple = header.each_with_index.reduce({}) do |h, (attr, i)|
            h.merge!(attr.to_sym => row[i])
          end
          Row[tuple]
        end
        Relation.new(header, body, opts[:meta])
      end
    end
  end
end
