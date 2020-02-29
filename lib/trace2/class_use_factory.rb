# frozen_string_literal: true

# Builds a ClassUse from TracePoint
class ClassUseFactory
  def self.build(trace_point:, caller_class:, stack_level:)
    ClassUse.new(
      trace_point_params(trace_point)
        .merge(caller_class: caller_class)
        .merge(stack_level: stack_level)
        .merge(top_of_stack: true)
    )
  end

  def self.trace_point_params(trace_point)
    {
      name: class_name(trace_point),
      method: trace_point.callee_id.to_s,
      path: trace_point.path,
      line: trace_point.lineno
    }
  end
  private_class_method :trace_point_params

  def self.class_name(trace_point)
    return trace_point.defined_class.to_s unless trace_point.defined_class.nil?

    trace_point.self.to_s
  end
  private_class_method :class_name
end
