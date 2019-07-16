require 'stringio'

module Relational
  module Writer
    class Html
      def call(relation, opts)
        buffer = StringIO.new
        if opts[:class]
          buffer.write("<table class=\"#{opts[:class]}\"")
        else
          buffer.write('<table>')
        end
        buffer.write('<thead><tr>')
        relation.header.each do |attr|
          buffer.write("<th>#{attr}</th>")
        end
        buffer.write('</tr></thead>')
        buffer.write('<tbody>')
        relation.body.each do |row|
          buffer.write('<tr>')
          relation.header.each do |attr|
            buffer.write("<td>#{row[attr]}</td>")
          end
          buffer.write('</tr>')
        end
        buffer.write('</tbody></table>')
        buffer.string
      end
    end
  end
end
