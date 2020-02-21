# frozen_string_literal: true

# Registers how a class was used during run time
class ClassUse
  attr_accessor :name, :method, :stack_level, :caller_class, :path

  def self.build(trace_point: nil, caller_class: nil, stack_level: nil)
    ClassUse.new(
      name: trace_point.defined_class.to_s,
      method: trace_point.callee_id.to_s,
      path: trace_point.path,
      stack_level: stack_level,
      caller_class: caller_class
    )
  end

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
end
