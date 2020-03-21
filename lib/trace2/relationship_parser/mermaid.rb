# frozen_string_literal: true

module Trace2
  module RelationshipParser
    # Class parses classes relationships to be used by mermaid.js
    class Mermaid
      def self.parse(classes_uses)
        flatten_callers(classes_uses).flat_map do |class_use|
          mermaid_relationship(class_use)
        end.reduce('', :+)
      end

      class << self
        private

        def flatten_callers(classes_uses)
          all_callers = classes_uses
          next_callers = classes_uses.flat_map(&:callees)
          until next_callers.empty?
            all_callers = all_callers.concat(next_callers)
            next_callers = next_callers.flat_map(&:callees)
          end
          all_callers
        end

        def mermaid_relationship(class_use)
          class_use.callees.map do |callee|
            "#{class_use.name}-->#{callee.name};\n"
          end
        end
      end
    end
  end
end
