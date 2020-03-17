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

    def self.trace_point_params(trace_point)
      {
        name: class_name(trace_point),
        method: trace_point.callee_id.to_s,
        path: trace_point.path,
        line: trace_point.lineno,
        event: trace_point.event
      }
    end
    private_class_method :trace_point_params

    def self.class_name(trace_point)
      current_class = trace_point.self
      if trace_point.defined_class == Kernel
        return trace_point.defined_class.to_s
      end
      if (current_class.is_a? Class) || (current_class.is_a? Module)
        return parse_class_name(current_class)
      end

      parse_instance_name(current_class)
    end

    def self.parse_class_name(current_class)
      return current_class.name unless current_class.name.nil?

      current_class.to_s.match(/^#<Class:(\S+)>$/)[1]
    end
    private_class_method :parse_class_name

    def self.parse_instance_name(current_class)
      current_class.class.name
    end
    private_class_method :parse_instance_name
  end
end
