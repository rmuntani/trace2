require 'forwardable'

# Responsable for listing all accessed classes
class ClassListing
  extend Forwardable

  attr_reader :accessed_classes, :callers

  def_delegators :@trace_point, :enable, :disable

  def initialize(class_use = ClassUse)
    @class_use = class_use
    @callers = []
    @trace_point = TracePoint.new(:call) do |tp|
      @callers << build_class_use(tp, caller, @callers)
    end
  end

  def accessed_classes
    @callers.map(&:name)
  end
  
  private

  def build_class_use(trace_point, call_stack, possible_callers)
    @class_use.build(trace_point, call_stack, possible_callers)
  end
end
