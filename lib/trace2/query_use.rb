# frozen_string_literal: true

# Class that queries ClassUse by parameters
# passed as a hash
class QueryUse
  attr_reader :classes_uses

  def initialize(classes_uses, action)
    @classes_uses = classes_uses
    @action = action
  end

  def self.reject(classes_uses)
    QueryUse.new(classes_uses, :reject)
  end

  def self.allow(classes_uses)
    QueryUse.new(classes_uses, :select)
  end

  def reject
    @action = :reject
    self
  end

  def allow
    @action = :select
    self
  end

  def where(query_parameters)
    @classes_uses = classes_uses.send(@action) do |class_use|
      matches_queries?(class_use, query_parameters)
    end
    self
  end

  private

  def matches_queries?(class_use, query_parameters)
    query_parameters.all? do |attribute, values|
      validation = "matches_#{attribute}?"
      class_use.send(validation, values)
    end
  end
end
