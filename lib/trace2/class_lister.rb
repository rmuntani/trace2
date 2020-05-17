# frozen_string_literal: true

require 'forwardable'

module Trace2
  # Responsable for listing all accessed classes
  # along with their dependencies
  class ClassLister
    extend Forwardable

    attr_accessor :classes_uses

    def_delegators :@trace_point, :enable

    def initialize(args = {})
      @event_processor = initialize_event_processor(args)
      @classes_uses = []
      @trace_point = TracePoint.new(:call, :b_call) do |tp|
        @event_processor.process_event(tp)
      end
    end

    def disable
      @trace_point.disable
      @event_processor.aggregate_uses
      @classes_uses = @event_processor.classes_uses
    end

    private

    def initialize_event_processor(args)
      filter = args[:filter] || []
      filter_parser = args[:filter_parser]
      event_processor = args[:event_processor] || Trace2::EventProcessor

      used_filter = if filter_parser.nil? || filter.empty?
                      filter
                    else
                      filter_parser.new(filter).parse
                    end

      event_processor.new(used_filter)
    end
  end
end
