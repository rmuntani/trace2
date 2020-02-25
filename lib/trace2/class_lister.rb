# frozen_string_literal: true

require 'forwardable'

# Responsable for listing all accessed classes
# along with their dependencies
class ClassLister
  extend Forwardable

  attr_accessor :classes_uses

  def_delegators :@trace_point, :enable

  def initialize
    @classes_uses = []
    @classes_stack = []
    @stack_level = caller.length

    @trace_point = TracePoint.new(:call, :b_call) do |tp|
      list_classes(tp)
    end
  end

  def disable
    @trace_point.disable
    aggregate_uses
  end

  def accessed_classes_names
    @classes_uses.map(&:name)
  end

  private

  def aggregate_uses
    @classes_uses = @classes_uses.concat(@classes_stack).reject(&:nil?)
    @classes_stack = []
  end

  def build_class_use(stack_level, trace_point)
    ClassUse.build(
      trace_point: trace_point,
      stack_level: stack_level,
      caller_class: caller_class(stack_level)
    )
  end

  def caller_class(stack_level)
    @classes_stack.reverse.find do |current_class|
      current_class.stack_level < stack_level
    end
  end

  def list_classes(trace_point)
    @classes_uses << @classes_stack.pop if @stack_level > caller.length
    @classes_stack.push(build_class_use(caller.length, trace_point))
    @stack_level = caller.length
  end
end
