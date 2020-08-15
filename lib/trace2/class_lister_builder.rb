# frozen_string_literal: true

require 'yaml'

module Trace2
  # Build a ClassLister instance depending on the type that
  # is passed.
  class ClassListerBuilder
    def initialize(class_lister: ClassLister)
      @class_lister = class_lister
    end

    def build(filter, type: :native)
      @type = type
      parsed_filter = build_filter(filter)
      event_processor = build_event_processor(parsed_filter)
      @class_lister.new(event_processor)
    end

    private

    Trace2::NATIVE = {
      event_processor: Trace2::EventProcessorC,
      filter_parser: Trace2::FilterParser.new
    }.freeze

    Trace2::RUBY = {
      event_processor: Trace2::EventProcessor,
      filter_parser: nil
    }.freeze

    def build_filter(unparsed_filter)
      return type_filter.parse(unparsed_filter) if type_filter

      unparsed_filter
    end

    def build_event_processor(filter)
      type_event.new(filter)
    end

    def type_event
      Object.const_get("Trace2::#{@type.upcase}")[:event_processor]
    end

    def type_filter
      Object.const_get("Trace2::#{@type.upcase}")[:filter_parser]
    end
  end
end
