# frozen_string_literal: true

# Registers how a class was used during run time
class ClassUse
  attr_accessor :name, :method, :stack_level, :caller_class, :path

  def initialize(
    name: nil, method: nil,
    caller_class: nil, stack_level: nil,
    path: nil
  )
    @name = name
    @method = method
    @caller_class = caller_class
    @stack_level = stack_level
    @path = path
  end

  def self.build(trace_point: nil, caller_class: nil, stack_level: nil)
    ClassUse.new(
      name: class_name(trace_point),
      method: trace_point.callee_id.to_s,
      path: trace_point.path,
      stack_level: stack_level,
      caller_class: caller_class
    )
  end

  def self.class_name(trace_point)
    return trace_point.defined_class.to_s unless trace_point.defined_class.nil?

    trace_point.self.to_s
  end
  private_class_method :class_name

  def callers_stack
    curr_class = caller_class
    callers_stack = []
    until curr_class.nil?
      callers_stack.push(curr_class)
      curr_class = curr_class.caller_class
    end
    callers_stack
  end
end
