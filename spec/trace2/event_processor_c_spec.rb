# frozen_string_literal: true

require 'spec_helper'
describe Trace2::EventProcessorC do
  describe '#new' do
    context 'when filter is empty' do
      it 'does not raise an error' do
        expect { Trace2::EventProcessorC.new([]) }.not_to raise_error
      end
    end

    context 'when filter is not empty' do
      it 'does not raise an error' do
        filter = %w[1 1 1 1 validate_name 1 MyClass allow filter]
        expect { Trace2::EventProcessorC.new(filter) }.not_to raise_error
      end
    end
  end

  describe 'validate if functions raise errors' do
    let(:processor) { Trace2::EventProcessorC.new([]) }

    it '#process_event' do
      expect do
        trace_point = TracePoint.trace do
          processor.process_event(trace_point)
        end

        # Simple call to check if C lib doesn't raise an error
        Simple.new.simple_call

        trace_point.disable
      end.not_to raise_error
    end

    it '#aggregate_uses' do
      expect { processor.aggregate_uses }.not_to raise_error
    end

    it '#classes_uses' do
      expect { processor.classes_uses }.not_to raise_error
    end
  end

  describe 'test all functions' do
    it 'returns a string with details of the class use' do
      class_lister_args = {
        filter: [],
        event_processor: Trace2::EventProcessorC
      }
      class_lister = Trace2::ClassLister.new(class_lister_args)

      class_lister.enable
      Simple.new.simple_call
      class_lister.disable

      classes_uses = class_lister.classes_uses
      simple_use = classes_uses.find do |cl|
        cl.match(/class: Simple/) && cl.match(/method: simple_call/)
      end

      expect(simple_use).to include 'class: Simple'
      expect(simple_use).to include 'lineno: 4'
      expect(simple_use).to include 'spec/fixtures/classes.rb'
      expect(simple_use).to include 'caller: nil'
      expect(simple_use).to include 'method: simple_call'
    end

    it 'returns an array ordered by call order' do
      class_lister_args = {
        filter: [],
        event_processor: Trace2::EventProcessorC
      }
      class_lister = Trace2::ClassLister.new(class_lister_args)

      class_lister.enable
      nested = Nested.new
      nested.nested_call
      class_lister.disable

      classes_uses = class_lister.classes_uses
      classes_names = classes_uses.map do |class_use|
        class_use.match(/class: ([\w|:]+)/)[1]
      end

      expect(classes_names).to eq [
        'Nested', 'Nested', 'Simple', 'Trace2::ClassLister', 'TracePoint'
      ]
    end

    it 'returns a filtered array' do
      class_lister_args = {
        filter: [
          {
            reject: [{ name: ['Simple'] }]
          },
          {
            reject: [{ name: ['Nested'], method: ['nested_call'] }]
          }
        ],
        event_processor: Trace2::EventProcessorC,
        filter_parser: Trace2::FilterParser
      }
      class_lister = Trace2::ClassLister.new(class_lister_args)

      class_lister.enable
      nested = Nested.new
      nested.nested_call
      nested.nested_simple_call
      class_lister.disable

      classes_uses = class_lister.classes_uses
      parsed_classes = classes_uses.map do |class_use|
        {
          name: class_use.match(/class: ([\w|:]+)/)[1],
          method: class_use.match(/method: ([\w|:]+)/)[1]
        }
      end

      expect(parsed_classes).not_to include(
        name: 'Simple', method: 'simple_call'
      )
      expect(parsed_classes).not_to include(
        name: 'Nested', method: 'nested_call'
      )
      expect(parsed_classes).to include(
        name: 'Nested', method: 'nested_simple_call'
      )
    end
  end
end
