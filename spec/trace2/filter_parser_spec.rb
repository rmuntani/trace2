# frozen_string_literal: true

require 'spec_helper'

describe Trace2::FilterParser do
  describe '#parse' do
    context 'when filter is empty' do
      it 'parses the filter' do
        filter = []
        parsed_filter = Trace2::FilterParser.parse(filter)

        expect(parsed_filter).to eq []
      end
    end

    context 'when filter has one action' do
      context 'when there is one validation' do
        context 'when the validation has one value' do
          it 'parses the filter' do
            filter = [{ allow: [{ name: ['MyClass'] }] }]
            parsed_filter = Trace2::FilterParser.parse(filter)

            expect(parsed_filter).to eq %w[
              filter
              allow
              validations name MyClass end_name end_validations
              end_allow
              end_filter
            ]
          end
        end

        context 'when the validation has multiple values' do
          it 'parses the filter' do
            filter = [{ allow: [{ name: %w[MyClass YourClass] }] }]
            parsed_filter = Trace2::FilterParser.parse(filter)

            expect(parsed_filter).to eq %w[
              filter
              allow
              validations
              name MyClass YourClass end_name
              end_validations
              end_allow
              end_filter
            ]
          end
        end
      end

      context 'when there is more than one validation' do
        context 'when the validations are applied in sequence' do
          it 'parses the filter' do
            filter = [{ allow: [{ name: ['MyClass'], method: ['yes'] }] }]
            parsed_filter = Trace2::FilterParser.parse(filter)

            expect(parsed_filter).to eq %w[
              filter
              allow
              validations
              name MyClass end_name
              method yes end_method
              end_validations
              end_allow
              end_filter
            ]
          end
        end

        context 'when the validations are applied in parallel' do
          it 'parses the filter' do
            filter = [{ allow: [{ name: ['MyClass'] }, { method: ['yes'] }] }]
            parsed_filter = Trace2::FilterParser.parse(filter)

            expect(parsed_filter).to eq %w[
              filter
              allow
              validations
              name MyClass end_name
              end_validations
              validations
              method yes end_method
              end_validations
              end_allow
              end_filter
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
      parsed_filter = Trace2::FilterParser.parse(filter)

      expect(parsed_filter).to eq %w[
        filter
        allow
        validations
        name MyClass end_name
        end_validations
        end_allow
        reject
        validations
        method no end_method
        end_validations
        end_reject
        end_filter
      ]
    end
  end

  context 'when there are multiple filters' do
    it 'parses the filters' do
      filter = [
        { allow: [{ name: ['MyClass'] }] },
        { reject: [{ method: ['no'] }] }
      ]
      parsed_filter = Trace2::FilterParser.parse(filter)

      expect(parsed_filter).to eq %w[
        filter
        allow
        validations
        name MyClass end_name
        end_validations
        end_allow
        end_filter
        filter
        reject
        validations
        method no end_method
        end_validations
        end_reject
        end_filter
      ]
    end
  end
end
