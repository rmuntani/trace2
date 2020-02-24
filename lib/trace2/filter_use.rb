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
    filter_parameters.each do |filter_method, parameters|
      send(filter_method, parameters) if filter_implemented?(filter_method)
    end
    self
  end

  private

  def filter_implemented?(filter)
    private_methods.include? filter
  end

  def path(paths)
    @classes_uses = @classes_uses.send(@action) do |class_use|
      paths.any? { |path| class_use.path.match(path) }
    end
  end

  def class_name(classes_names)
    @classes_uses = @classes_uses.send(@action) do |class_use|
      classes_names.any? { |path| class_use.name.match(path) }
    end
  end

  def method(methods)
    @classes_uses = @classes_uses.send(@action) do |class_use|
      methods.any? { |method| class_use.method.match(method) }
    end
  end

  def caller_class(hash)
    @classes_uses = @classes_uses.send(@action) do |class_use|
      class_use.caller_class &&
        (!filter_caller(class_use).where(hash).classes_uses.empty? ||
         !filter_caller(class_use).where(caller_class: hash).classes_uses.empty?)
    end
  end

  def filter_caller(class_use)
    FilterUse.new([class_use.caller_class], @action)
  end
end
