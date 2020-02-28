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
    @callers_stack = []
    @stack_level = caller.length

    @trace_point = TracePoint.new(:call, :b_call) do |tp|
      process_event(tp)
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
    @classes_uses = @classes_uses.concat(@callers_stack).reject(&:nil?)
    @callers_stack = []
  end

  def process_event(trace_point)
    @classes_uses << @callers_stack.pop if @stack_level > caller.length
    @stack_level = caller.length
    update_current_caller
    @callers_stack.push(build_class_use(trace_point))
    @current_caller.top_of_stack = false unless @current_caller.nil?
  end

  def build_class_use(trace_point)
    ClassUse.build(
      trace_point: trace_point,
      stack_level: @stack_level,
      caller_class: @current_caller
    )
  end

  def update_current_caller
    @current_caller = @callers_stack.reverse.find do |current_class|
      current_class.stack_level < @stack_level
    end
  end
end
