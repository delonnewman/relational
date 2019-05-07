require 'json'

module Relational
  module Deserializer
    class Json
      def call(str)
        JSON.parse(str).lazy.map do |row|
          row.transform_keys(&:to_sym)
        end
      end
    end
  end
end