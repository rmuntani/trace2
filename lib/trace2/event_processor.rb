# frozen_string_literal: true

module Trace2
  # Processes a TracePoint event
  class EventProcessor
    attr_accessor :classes_uses

    def initialize(filter_by)
      @selector = QueryUse.where(filter_by)
      @classes_uses = []
      @callers_stack = []
      @stack_level = caller.length
    end

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

    private

    def build_class_use(trace_point, caller_class)
      ClassUseFactory.build(
        trace_point: trace_point,
        stack_level: @stack_level,
        caller_class: caller_class
      )
    end

    def update_callers_stack(trace_point)
      remove_exited_callers_from_stack
      current_class_use = build_class_use(trace_point, allowed_caller)
      update_top_of_callers(current_class_use)
      @callers_stack.unshift(current_class_use)
    end

    def update_top_of_callers(callee)
      caller_class = callee.caller_class
      return if caller_class.nil?

      caller_class.add_callee(callee) unless @selector.filter(callee).nil?
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

    def allowed_caller
      possible_caller = @callers_stack.first
      class_caller = @selector.filter(possible_caller)
      while !possible_caller.nil? && class_caller.nil?
        possible_caller = possible_caller.caller_class
        class_caller = @selector.filter(possible_caller)
      end
      class_caller
    end
  end
end
