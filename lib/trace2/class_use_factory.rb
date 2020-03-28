# frozen_string_literal: true

module Trace2
  # Builds a ClassUse from TracePoint
  class ClassUseFactory
    CLASS_POINTER_FORMAT = '0x[0-9abcdef]+'

    def self.build(trace_point:, caller_class:, stack_level:)
      ClassUse.new(
        trace_point_params(trace_point)
        .merge(caller_class: caller_class)
        .merge(stack_level: stack_level)
      )
    end

    def self.class_name(trace_point)
      Trace2::NameFinder.class_name(trace_point.self)
    end

    class << self
      def trace_point_params(trace_point)
        {
          name: class_name(trace_point),
          method: trace_point.callee_id.to_s,
          path: trace_point.path,
          line: trace_point.lineno,
          event: trace_point.event
        }
      end
    end
  end
end
