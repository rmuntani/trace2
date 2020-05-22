# frozen_string_literal: true

require 'spec_helper'

describe Trace2::FilterParser do
  describe '#parse' do
    context 'when filter is empty' do
      it 'parses the filter' do
        filter = []
        parsed_filter = Trace2::FilterParser.new(filter).parse

        expect(parsed_filter).to eq ['0']
      end
    end

    context 'when filter has one action' do
      context 'when there is one validation' do
        context 'when the validation has one value' do
          it 'parses the filter' do
            filter = [{ allow: [{ name: ['MyClass'] }] }]
            parsed_filter = Trace2::FilterParser.new(filter).parse

            expect(parsed_filter).to eq %w[
              1
              1
              1
              1
              validate_name
              1
              MyClass
              allow
              filter
            ]
          end
        end

        context 'when the validation has multiple values' do
          it 'parses the filter' do
            filter = [{ allow: [{ name: %w[MyClass YourClass] }] }]
            parsed_filter = Trace2::FilterParser.new(filter).parse

            expect(parsed_filter).to eq %w[
              1
              1
              1
              1
              validate_name
              2
              MyClass
              YourClass
              allow
              filter
            ]
          end
        end

        context 'when the validation has a non-array value' do
          it 'parses the filter' do
            filter = [{
              reject: [{ top_of_stack: true, bottom_of_stack: false }]
            }]
            parsed_filter = Trace2::FilterParser.new(filter).parse

            expect(parsed_filter).to eq %w[
              1
              1
              1
              2
              validate_top_of_stack
              1
              true
              validate_bottom_of_stack
              1
              false
              reject
              filter
            ]
          end
        end

        context 'when the validation validates a caller class' do
          it 'parses the filter' do
            filter = [{
              reject: [{
                caller_class: { name: ['Yes'], bottom_of_stack: false }
              }]
            }]
            parsed_filter = Trace2::FilterParser.new(filter).parse

            expect(parsed_filter).to eq %w[
              1
              1
              1
              1
              validate_caller_class
              2
              validate_name
              1
              Yes
              validate_bottom_of_stack
              1
              false
              reject
              filter
            ]
          end
        end
      end

      context 'when there is more than one validation' do
        context 'when the validations are applied in sequence' do
          it 'parses the filter' do
            filter = [{ allow: [{ name: ['MyClass'], method: ['yes'] }] }]
            parsed_filter = Trace2::FilterParser.new(filter).parse

            expect(parsed_filter).to eq %w[
              1
              1
              1
              2
              validate_name
              1
              MyClass
              validate_method
              1
              yes
              allow
              filter
            ]
          end
        end

        context 'when the validations are applied in parallel' do
          it 'parses the filter' do
            filter = [{ allow: [{ name: ['MyClass'] }, { method: ['yes'] }] }]
            parsed_filter = Trace2::FilterParser.new(filter).parse

            expect(parsed_filter).to eq %w[
              1
              1
              2
              1
              validate_name
              1
              MyClass
              1
              validate_method
              1
              yes
              allow
              filter
            ]
          end
        end
      end
    end
  end

  context 'when there are two actions inside a filter' do
    it 'parses the filter' do
      filter = [{
        allow: [{ name: ['MyClass'] }],
        reject: [{ method: ['no'] }]
      }]
      parsed_filter = Trace2::FilterParser.new(filter).parse

      expect(parsed_filter).to eq %w[
        1
        2
        1
        1
        validate_name
        1
        MyClass
        allow
        1
        1
        validate_method
        1
        no
        reject
        filter
      ]
    end
  end

  context 'when there are multiple filters' do
    it 'parses the filters' do
      filter = [
        { allow: [{ name: ['MyClass'] }] },
        { reject: [{ method: ['no'] }] }
      ]
      parsed_filter = Trace2::FilterParser.new(filter).parse

      expect(parsed_filter).to eq %w[
        2
        1
        1
        1
        validate_name
        1
        MyClass
        allow
        filter
        1
        1
        1
        validate_method
        1
        no
        reject
        filter
      ]
    end
  end
end
