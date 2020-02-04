require 'forwardable'

class ClassListing
  extend Forwardable

  attr_reader :accessed_classes

  def_delegators :@trace_point, :enable, :disable

  def initialize
    @accessed_classes = []
    @trace_point = TracePoint.new(:call) do |tp|
      @accessed_classes << tp.defined_class.to_s
    end
  end
end
