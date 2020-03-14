# frozen_string_literal: true

# Parses the relationship of classes to a format that allows
# it to be shown as a graph
class ClassesRelationshipParser
  def self.parse(classes_uses)
    flatten_callers(classes_uses).flat_map do |class_use|
      relationship_hash(class_use)
    end
  end

  def self.flatten_callers(classes_uses)
    all_callers = classes_uses
    next_callers = classes_uses.flat_map(&:callees)
    until next_callers.empty?
      all_callers = all_callers.concat(next_callers)
      next_callers = next_callers.flat_map(&:callees)
    end
    all_callers
  end
  private_class_method :flatten_callers

  def self.relationship_hash(class_use)
    class_use.callees.map do |callee|
      { caller: class_use.name, callee: callee.name }
    end
  end
  private_class_method :relationship_hash
end
