# frozen_string_literal: true

# Class that queries ClassUse by parameters
# passed as a hash
class QueryUse
  attr_reader :classes_uses

  def initialize(queries)
    @queries = queries
  end

  def self.where(queries)
    QueryUse.new(queries)
  end

  def filter(class_use)
    class_use if valid_use?(class_use)
  end

  def select(classes_uses)
    classes_uses.select do |class_use|
      valid_use?(class_use)
    end
  end

  private

  def valid_use?(class_use)
    @queries.all? do |query|
      query.all? do |action, validations|
        send(action, matches_validations?(class_use, validations))
      end
    end
  end

  def allow(query_result)
    query_result
  end

  def reject(query_result)
    !query_result
  end

  def matches_validations?(class_use, validations)
    validations.all? do |attribute, values|
      validation = "matches_#{attribute}?"
      class_use.send(validation, values)
    end
  end
end
