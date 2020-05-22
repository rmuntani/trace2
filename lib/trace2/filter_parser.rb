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
        parse_validation(validation)
      end
    end

    def parse_validation(validation)
      validation.each do |attribute, values|
        @parsed_filter.push("validate_#{attribute}")
        current_parser = parse_values_method(values)
        if respond_to?(current_parser, true)
          send(current_parser, values)
        else
          @parsed_filter.push(1)
          @parsed_filter.push(values.to_s)
        end
      end
    end

    def parse_values_method(values)
      "parse_#{values.class.to_s.downcase}"
    end

    def parse_array(values)
      @parsed_filter.push(values.length)
      @parsed_filter.concat(values)
    end

    def parse_hash(values)
      @parsed_filter.push(values.keys.length)
      parse_validation(values)
    end
  end
end
