# frozen_string_literal: true

module Trace2
  # Generates a graph in .dot format from an array of
  # ClassUse
  class GraphGenerator
    def run(output_path, class_lister)
      parsed_classes = parse_classes(class_lister.classes_uses)
      File.write(output_path, base_graph(parsed_classes))
    end

    private

    def base_graph(parsed_classes)
      <<~FILE
        digraph {
        #{parsed_classes}
        }
      FILE
    end

    def parse_classes(classes_uses)
      classes_uses.flat_map do |class_use|
        caller_relationship(class_use) + callee_relationships(class_use)
      end.uniq.join("\n")
    end

    def caller_relationship(class_use)
      return [] unless class_use.caller_class

      [to_graph(class_use.caller_class, class_use)]
    end

    def callee_relationships(class_use)
      class_use.callees.map { |callee| to_graph(class_use, callee) }
    end

    def to_graph(caller_class, callee)
      "\s\s\"#{caller_class.name}\" -> \"#{callee.name}\""
    end
  end
end
