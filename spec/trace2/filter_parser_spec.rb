# frozen_string_literal: true

require 'spec_helper'

describe Trace2::FilterParser do
  subject(:filter_parser) { described_class.new }

  describe '#parse' do
    subject(:parsed_filter) { filter_parser.parse(filter) }

    context 'when filter is empty' do
      let(:filter) { [] }
      let(:expected_parse) { ['0'] }

      it { expect(parsed_filter).to eq(expected_parse) }
    end

    context 'when filter has one action with a single-value validation' do
      let(:filter) { [{ allow: [{ name: ['MyClass'] }] }] }
      let(:expected_parse) do
        %w[1 1 1 1 validate_name 1 MyClass allow filter]
      end

      it { expect(parsed_filter).to eq(expected_parse) }
    end

    context 'when filter has one action with a multiple-values validation' do
      let(:filter) { [{ allow: [{ name: %w[MyClass YourClass] }] }] }
      let(:expected_parse) do
        %w[1 1 1 1 validate_name 2 MyClass YourClass allow filter]
      end

      it { expect(parsed_filter).to eq(expected_parse) }
    end

    context 'when filter has one action with a non-array value validation' do
      let(:filter) do
        [{
          reject: [{ top_of_stack: true, bottom_of_stack: false }]
        }]
      end
      let(:expected_parse) do
        %w[ 1 1 1 2 validate_top_of_stack 1 true
            validate_bottom_of_stack 1 false reject filter ]
      end

      it { expect(parsed_filter).to eq(expected_parse) }
    end

    context 'when filter has a validation for caller class' do
      let(:filter) do
        [{
          reject: [{
            caller_class: { name: ['Yes'], bottom_of_stack: false }
          }]
        }]
      end
      let(:expected_parse) do
        %w[ 1 1 1 1 validate_caller_class 2 validate_name
            1 Yes validate_bottom_of_stack 1 false reject filter]
      end

      it { expect(parsed_filter).to eq(expected_parse) }
    end

    context 'when the filter has sequential validations' do
      let(:filter) do
        [{ allow: [{ name: ['MyClass'], method: ['yes'] }] }]
      end
      let(:expected_parse) do
        %w[ 1 1 1 2 validate_name 1 MyClass
            validate_method 1 yes allow filter ]
      end

      it { expect(parsed_filter).to eq(expected_parse) }
    end

    context 'when the filter has parallel validations' do
      let(:filter) do
        [{ allow: [{ name: ['MyClass'] }, { method: ['yes'] }] }]
      end
      let(:expected_parse) do
        %w[ 1 1 2 1 validate_name 1 MyClass 1
            validate_method 1 yes allow filter ]
      end

      it { expect(parsed_filter).to eq(expected_parse) }
    end

    context 'when there are two actions inside a filter' do
      let(:filter) do
        [{
          allow: [{ name: ['MyClass'] }],
          reject: [{ method: ['no'] }]
        }]
      end
      let(:expected_parse) do
        %w[ 1 2 1 1 validate_name 1 MyClass allow
            1 1 validate_method 1 no reject filter ]
      end

      it { expect(parsed_filter).to eq(expected_parse) }
    end

    context 'when there are multiple filters inside a filter' do
      let(:filter) do
        [
          { allow: [{ name: ['MyClass'] }] },
          { reject: [{ method: ['no'] }] }
        ]
      end
      let(:expected_parse) do
        %w[ 2 1 1 1 validate_name 1 MyClass allow filter
            1 1 1 validate_method 1 no reject filter ]
      end

      it { expect(parsed_filter).to eq(expected_parse) }
    end
  end
end
