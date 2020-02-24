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
  end

  def allow
    @action = :select
  end

  def where(filter_parameters)
    filter_parameters.each do |filter_method, parameters|
      send(filter_method, parameters) if filter_implemented?(filter_method)
    end
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
end