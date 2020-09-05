# frozen_string_literal: true

module Trace2
  # Processes a TracePoint event, generating an array
  # of ClassUse
  class EventProcessor
    attr_accessor :classes_uses
    EVENTS = %i[call b_call].freeze

    def initialize(filter_by, kernel: Kernel, query_use: QueryUse,
                   class_use_factory: ClassUseFactory)
      @callers_stack = []
      @classes_uses = []
      @class_use_factory = class_use_factory
      @kernel = kernel
      @selector = query_use.where(filter_by)
      @stack_level = @kernel.caller.length
    end

    def aggregate_uses
      @classes_uses = @callers_stack
                      .map { |caller_class| @selector.filter(caller_class) }
                      .concat(@classes_uses)
                      .reject(&:nil?)
      @callers_stack = []
    end

    def process_event(trace_point)
      @stack_level = @kernel.caller.length

      remove_exited_callers_from_stack
      current_class_use = build_class_use(trace_point, current_caller)
      update_top_of_stack(current_class_use)

      @callers_stack.unshift(current_class_use)
    end

    def events
      EVENTS
    end

    private

    def remove_exited_callers_from_stack
      while class_exited?(@callers_stack.first)
        @classes_uses << @selector.filter(@callers_stack.shift)
      end
    end

    def build_class_use(trace_point, caller_class)
      @class_use_factory.build(
        trace_point: trace_point,
        stack_level: @stack_level,
        caller_class: caller_class
      )
    end

    def update_top_of_stack(callee)
      caller_class = callee.caller_class
      return if caller_class.nil?

      caller_class.add_callee(callee) unless @selector.filter(callee).nil?
    end

    def class_exited?(current_class)
      current_class && current_class.stack_level >= @stack_level
    end

    def current_caller
      @callers_stack.drop_while do |possible_caller|
        possible_caller.nil? || @selector.filter(possible_caller).nil?
      end.first
    end
  end
end
