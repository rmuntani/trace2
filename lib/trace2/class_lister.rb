# frozen_string_literal: true

require 'forwardable'

module Trace2
  # Responsable for listing all accessed classes
  # along with their dependencies
  class ClassLister
    extend Forwardable

    attr_accessor :classes_uses

    def_delegators :@trace_point, :enable

    def initialize(filter_by = [], event_processor = Trace2::EventProcessor)
      @event_processor = event_processor.new(filter_by)
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
  end
end
