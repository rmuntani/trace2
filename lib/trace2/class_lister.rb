# frozen_string_literal: true

require 'forwardable'

# Responsable for listing all accessed classes
# along with their dependencies
class ClassLister
  extend Forwardable

  attr_accessor :classes_uses

  def_delegators :@trace_point, :enable

  def initialize(filter_by = [])
    @selector = QueryUse.where(filter_by)
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
    @classes_uses = @callers_stack
                    .map { |caller_class| @selector.filter(caller_class) }
                    .concat(@classes_uses)
                    .reject(&:nil?)
    @callers_stack = []
  end

  def process_event(trace_point)
    @classes_uses << caller_to_classes_uses if @stack_level > caller.length
    @stack_level = caller.length
    update_callers_stack(trace_point)
  end

  def build_class_use(trace_point, caller_class)
    ClassUseFactory.build(
      trace_point: trace_point,
      stack_level: @stack_level,
      caller_class: caller_class
    )
  end

  def update_callers_stack(trace_point)
    remove_exited_callers_from_stack
    mark_as_not_top_of_stack(@callers_stack.first)
    current_class_use = build_class_use(trace_point, @callers_stack.first)
    @callers_stack.unshift(current_class_use)
  end

  def remove_exited_callers_from_stack
    while class_exited(@callers_stack.first)
      @classes_uses << caller_to_classes_uses
    end
  end

  def caller_to_classes_uses
    @selector.filter(@callers_stack.shift)
  end

  def class_exited(current_class)
    current_class && current_class.stack_level >= @stack_level
  end

  def mark_as_not_top_of_stack(current_caller)
    current_caller.top_of_stack = false unless current_caller.nil?
  end
end
