require 'forwardable'

# Responsable for listing all accessed classes
class ClassListing
  extend Forwardable

  attr_reader :accessed_classes, :callers

  def_delegators :@trace_point, :enable, :disable

  def initialize
    @accessed_classes = []
    @callers = []
    @trace_point = TracePoint.new(:call) do |tp|
      @accessed_classes << tp.defined_class.to_s
      # @callers << caller_locations
      @callers << { class: tp.defined_class.to_s, method: tp.callee_id.to_s, caller: find_caller(caller, @callers), call_stack: caller }
    end
  end
  
  private

  def find_caller(call_stack, registered_callees)
    caller_method = parse_caller_method(call_stack)
    caller_class = registered_callees.find do |registered_callee|
      registered_callee[:method] == caller_method
    end
    
    caller_class.nil? ? nil : caller_class[:class]
  end

  def parse_caller_method(call_stack)
    call_stack.map do |curr_call|
      methods = curr_call.match(/\`(\S+)'$/)
      methods[1] if !methods.nil?
    end[1]
  end
end
