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
    query_parameters.map do |query_method, parameters|
      return true unless query_implemented?(query_method)

      send(query_method, class_use, parameters)
    end.reduce(:&)
  end

  def query_implemented?(query)
    private_methods.include? query
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

  def top_of_stack(class_use, is_top_of_stack)
    class_use.top_of_stack == is_top_of_stack
  end

  def caller_class(class_use, query_parameters)
    class_use.callers_stack.any? do |caller_use|
      matches_queries?(caller_use, query_parameters)
    end
  end
end
