# frozen_string_literal: true

require 'spec_helper'

describe Trace2::EventProcessorC do
  describe '#new' do
    it 'does not raise an error' do
      expect { Trace2::EventProcessorC.new([]) }.not_to raise_error
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
    it 'for a simple class use' do
      class_lister = Trace2::ClassLister.new([], Trace2::EventProcessorC)

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
      class_lister = Trace2::ClassLister.new([], Trace2::EventProcessorC)

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
  end
end
