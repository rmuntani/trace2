# frozen_string_literal: true

require 'spec_helper'

# This file tests how EventProcessorC behaves when used with
# a filter and a class lister. It was separated from the regular
# spec file due to it's dependency on othe classes' implementations
describe Trace2::EventProcessorC, :integration do
  subject(:classes_uses) do
    class_lister.classes_uses
  end

  let(:class_lister) do
    Trace2::ReportingToolsFactory
      .new
      .build(filter, type: :native)[:class_lister]
  end

  context 'when filter is empty' do
    let(:filter) { [] }

    context 'when Simple class is used' do
      subject(:parsed_simple_use) do
        classes_uses.find do |use|
          use.match(/class: Simple/) && use.match(/method: simple_call/)
        end
      end

      before do
        class_lister.enable
        Simple.new.simple_call
        class_lister.disable
      end

      it 'returns a string with details of the class use' do
        expect(parsed_simple_use).to include(
          'class: Simple', 'lineno: 4', 'spec/fixtures/classes.rb',
          'caller: nil', 'method: simple_call'
        )
      end
    end

    context 'when Nested class is used' do
      before do
        class_lister.enable
        nested = Nested.new
        nested.nested_call
        class_lister.disable
      end

      let(:classes_names) do
        class_lister.classes_uses.map do |class_use|
          class_use.match(/class: ([\w|:]+)/)[1]
        end.first(3)
      end

      it 'returns classes uses ordered by call order' do
        expect(classes_names).to eq %w[
          Nested Nested Simple
        ]
      end
    end
  end

  context 'when filter is not empty' do
    context 'when Nested class is used' do
      let(:filter) do
        [
          {
            reject: [{ name: ['Simple'] }]
          },
          {
            reject: [{ name: ['Nested'], method: ['nested_call'] }]
          }
        ]
      end
      let(:parsed_classes) do
        class_lister.classes_uses.map do |class_use|
          {
            name: class_use.match(/class: ([\w|:]+)/)[1],
            method: class_use.match(/method: ([\w|:]+)/)[1]
          }
        end
      end
      let(:excluded_uses) do
        [{
          name: 'Simple', method: 'simple_call'
        },
         name: 'Nested', method: 'nested_call']
      end

      before do
        class_lister.enable
        nested = Nested.new
        nested.nested_call
        nested.nested_simple_call
        class_lister.disable
      end

      it 'excludes classes that don\'t match the filter' do
        expect(parsed_classes).not_to include(excluded_uses)
      end

      it 'includes classes that match the filter' do
        expect(parsed_classes).to include(
          name: 'Nested', method: 'nested_simple_call'
        )
      end
    end

    context 'when ComplexNesting class is used' do
      let(:filter) do
        [
          {
            allow: [{
              name: ['Simple'],
              caller_class: { name: ['ComplexNesting'] }
            }]
          },
          {
            reject: [{ caller_class: { name: ['Nested'] } }]
          }
        ]
      end
      let(:parsed_classes) do
        class_lister.classes_uses.map do |class_use|
          {
            name: class_use.match(/class: ([\w|:]+)/)[1],
            method: class_use.match(/method: ([\w|:]+)/)[1],
            caller_class: class_use.match(/caller: ([\w|:]+)/)[1]
          }
        end
      end
      let(:expected_uses) do
        [{
          name: 'Simple',
          method: 'simple_call',
          caller_class: 'ComplexNesting'
        }]
      end

      before do
        class_lister.enable
        complex_nesting = ComplexNesting.new
        complex_nesting.complex_call
        class_lister.disable
      end

      it 'returns the classes uses' do
        expect(parsed_classes).to eq(expected_uses)
      end
    end
  end

  context 'when the filter has a regex' do
    let(:filter) do
      [{ allow: [{ method: [/simple/] }] }]
    end
    let(:parsed_classes) do
      class_lister.classes_uses.map do |class_use|
        {
          name: class_use.match(/class: ([\w|:]+)/)[1],
          method: class_use.match(/method: ([\w|:]+)/)[1],
          caller_class: class_use.match(/caller: ([\w|:]+)/)[1]
        }
      end
    end
    let(:expected_uses) do
      [
        { name: 'Simple',
          method: 'simple_call',
          caller_class: 'ComplexNesting' },
        { name: 'Simple', method: 'simple_call', caller_class: 'Nested' },
        {
          name: 'ComplexNesting',
          method: 'complex_simple_call',
          caller_class: 'ComplexNesting'
        },
        {
          name: 'Nested',
          method: 'nested_simple_call',
          caller_class: 'ComplexNesting'
        }
      ]
    end

    before do
      class_lister.enable
      complex_nesting = ComplexNesting.new
      complex_nesting.complex_call
      class_lister.disable
    end

    it 'applies the regex filter to the classes uses' do
      expect(parsed_classes).to eq(expected_uses)
    end
  end
end
