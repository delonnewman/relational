require 'json'

module Relational
  module Reader
    class Json
      def call(str, _opts)
        JSON.parse(str).lazy.map do |row|
          row.transform_keys(&:to_sym)
        end
      end
    end
  end
end