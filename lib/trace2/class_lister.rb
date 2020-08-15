# frozen_string_literal: true

require 'forwardable'

module Trace2
  # Responsable for listing all accessed classes
  # along with their dependencies
  class ClassLister
    extend Forwardable

    attr_accessor :classes_uses

    def_delegators :@trace_point, :enable

    def initialize(event_processor, trace_point = TracePoint)
      @event_processor = event_processor
      @classes_uses = []
      @trace_point = trace_point.new(*@event_processor.events) do |tp|
        @event_processor.process_event(tp)
      end
    end

    def disable
      @trace_point.disable
      @event_processor.aggregate_uses
      @classes_uses = @event_processor.classes_uses
    end
  end
end
