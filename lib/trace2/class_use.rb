# frozen_string_literal: true

# Registers how a class was used during run time
class ClassUse
  attr_reader :caller_name, :call_stack, :name, :method

  CALLER_LINE = 1

  def initialize(name: nil, method: nil, caller_name: nil, call_stack: nil)
    @name = name
    @method = method
    @caller_name = caller_name
    @call_stack = call_stack
  end

  def self.build(trace_point, call_stack, possible_callers)
    class_use = ClassUse.new(
      call_stack: call_stack,
      name: trace_point.defined_class.to_s,
      method: trace_point.callee_id
    )
    class_use.define_caller(possible_callers)
    class_use
  end

  def define_caller(possible_callers)
    @caller_name = find_caller_name(possible_callers)
  end

  private

  def find_caller_name(possible_callers)
    caller_class = possible_callers&.find do |possible_caller|
      possible_caller.call_stack.first == call_stack[CALLER_LINE]
    end
    return if caller_class.nil?

    caller_class.name
  end

  def source_location(str)
    str.match(/^\.rb/)[1]
  end
end
