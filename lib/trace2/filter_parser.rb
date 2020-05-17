# frozen_string_literal: true

module Trace2
  # Class that queries ClassUse by parameters
  # passed as a hash
  class FilterParser
    def initialize(filters)
      @filters = filters
      @parsed_filter = [filters.length]
    end

    def parse
      parse_filters
      @parsed_filter.map(&:to_s)
    end

    private

    def parse_filters
      @filters.each do |filter|
        @parsed_filter.push(filter.length)
        filter.each do |action, validations|
          parse_validations(validations)
          @parsed_filter.push(action.to_s)
        end
        @parsed_filter.push('filter')
      end
    end

    def parse_validations(validations)
      @parsed_filter.push(validations.length)
      validations.each do |validation|
        @parsed_filter.push(validation.length)
        validation.each do |attribute, values|
          @parsed_filter.push("validate_#{attribute}")
          @parsed_filter.push(values.length)
          @parsed_filter.concat(values)
        end
      end
    end
  end
end
