require 'json'

module Relational
  module Writer
    class Json
      def call(relation, _opts)
        relation.body.map(&:to_h).to_a.to_json
      end
    end
  end
end