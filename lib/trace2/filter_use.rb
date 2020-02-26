# frozen_string_literal: true

# Class that filters ClassUse by parameters
# passed as a hash
class FilterUse
  attr_reader :classes_uses

  def initialize(classes_uses, action)
    @classes_uses = classes_uses
    @action = action
  end

  def self.reject(classes_uses)
    FilterUse.new(classes_uses, :reject)
  end

  def self.allow(classes_uses)
    FilterUse.new(classes_uses, :select)
  end

  def reject
    @action = :reject
    self
  end

  def allow
    @action = :select
    self
  end

  def where(filter_parameters)
    @classes_uses = classes_uses.send(@action) do |class_use|
      matches_filters?(class_use, filter_parameters)
    end
    self
  end

  private

  def matches_filters?(class_use, filter_parameters)
    filter_parameters.map do |filter_method, parameters|
      return true unless filter_implemented?(filter_method)

      send(filter_method, class_use, parameters)
    end.reduce(:&)
  end

  def filter_implemented?(filter)
    private_methods.include? filter
  end

  def path(class_use, paths)
    paths.any? { |path| class_use.path.match(path) }
  end

  def class_name(class_use, classes_names)
    classes_names.any? { |class_name| class_use.name.match(class_name) }
  end

  def method(class_use, methods)
    methods.any? { |method| class_use.method.match(method) }
  end

  def caller_class(class_use, filter_parameters)
    class_use.callers_stack.any? do |caller_use|
      matches_filters?(caller_use, filter_parameters)
    end
  end
end
