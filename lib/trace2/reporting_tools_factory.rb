# frozen_string_literal: true

module Trace2
  # Builds a ClassLister and GraphGenerator instance depending on the type
  # that is passed.
  class ReportingToolsFactory
    def initialize(class_lister: ClassLister)
      @class_lister = class_lister
    end

    def build(filter, type: :native)
      @type = type
      {
        class_lister: build_class_lister(filter),
        graph_generator: type_options[:graph_generator]
      }
    end

    private

    Trace2::NATIVE = {
      event_processor: Trace2::EventProcessorC,
      filter_parser: Trace2::FilterParser.new,
      graph_generator: Trace2::GraphGeneratorC.new
    }.freeze

    Trace2::RUBY = {
      event_processor: Trace2::EventProcessor,
      filter_parser: nil,
      graph_generator: Trace2::GraphGenerator.new
    }.freeze

    def build_class_lister(filter)
      parsed_filter = build_filter(filter)
      event_processor = type_options[:event_processor].new(parsed_filter)
      @class_lister.new(event_processor)
    end

    def build_filter(unparsed_filter)
      filter_parser = type_options[:filter_parser]
      return filter_parser.parse(unparsed_filter) if filter_parser

      unparsed_filter
    end

    def type_options
      Object.const_get("Trace2::#{@type.upcase}")
    end
  end
end
