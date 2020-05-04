# frozen_string_literal: true

module Trace2
  # Parses a filter, so the extension can
  # easily use it
  class FilterParser
    def self.parse(filters)
      filters.flat_map do |filter|
        filter.flat_map do |action, validations|
          validations.flat_map do |validation|
            validation.flat_map do |attribute, values|
              [attribute.to_s, values, "end_#{attribute}"].flatten
            end.unshift('validations').push('end_validations')
          end.unshift(action.to_s).push("end_#{action}")
        end.unshift('filter').push('end_filter')
      end
    end
  end
end
