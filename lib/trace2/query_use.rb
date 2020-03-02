# frozen_string_literal: true

# Class that queries ClassUse by parameters
# passed as a hash
class QueryUse
  attr_reader :classes_uses

  def initialize(query_parameters)
    @queries = query_parameters
  end

  def self.where(query_parameters)
    QueryUse.new(query_parameters)
  end

  def select(classes_uses)
    selected_classes = classes_uses
    @queries.each do |query|
      query.each do |action, validations|
        selected_classes = apply_validation(
          selected_classes, action, validations
        )
      end
    end
    selected_classes
  end

  private

  def filter_action(action)
    return :select if action == :allow

    :reject
  end

  def apply_validation(classes_uses, action, validations)
    classes_uses.send(filter_action(action)) do |class_use|
      matches_queries?(class_use, validations)
    end
  end

  def matches_queries?(class_use, query_parameters)
    query_parameters.all? do |attribute, values|
      validation = "matches_#{attribute}?"
      class_use.send(validation, values)
    end
  end
end
