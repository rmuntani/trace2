# frozen_string_literal: true

module Trace2
  module RelationshipParser
    # Class parses classes relationships to be used by D3.js
    class D3
      def self.parse(classes_uses)
        flatten_callers(classes_uses).flat_map do |class_use|
          relationship_hash(class_use)
        end.to_json
      end

      class << self
        def flatten_callers(classes_uses)
          all_callers = classes_uses
          next_callers = classes_uses.flat_map(&:callees)
          until next_callers.empty?
            all_callers = all_callers.concat(next_callers)
            next_callers = next_callers.flat_map(&:callees)
          end
          all_callers
        end

        def relationship_hash(class_use)
          class_use.callees.map do |callee|
            { source: class_use.name, target: callee.name }
          end
        end
      end
    end
  end
end
