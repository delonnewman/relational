require 'activerecord'

module Relational
  module ActiveRecord
    module Relation
      def self.included(base)
        base.include(InstanceMethods)
        base.extend(ClassMethods)
        base.extend(Relational)
      end

      module InstanceMethods
        def to_proc
          lambda do |key|
            self[key]
          end
        end

        def to_h
          attributes.reduce({}) do |h, (k, v)|
            h.merge(k.to_sym => v)
          end
        end

        def to_a
          attributes.map { |(k, v)| [k.to_sym, v] }
        end

        def transform_keys
          if block_given?
            Projection.new(to_h.transform_keys(&Proc.new), self.class.header.map(&Proc.new))
          else
            raise 'A block is required to transform keys'
          end
        end
      end

      module ClassMethods
        def header
          @@header ||= attribute_names.map(&:to_sym)
        end

        def body
          all
        end
      end
    end
  end
end
