# frozen_string_literal: true

require 'spec_helper'

describe Trace2::EventProcessor do
  def setup_processor_with_state(
    classes_uses = [], stack_level = 1, callers_stack = []
  )
    Trace2::EventProcessor.new([]).tap do |event_processor|
      event_processor.instance_variable_set(:@classes_uses, classes_uses)
      event_processor.instance_variable_set(:@stack_level, stack_level)
      event_processor.instance_variable_set(:@callers_stack, callers_stack)
    end
  end

  describe '#process_event' do
    context 'when stack level reduces' do
      it 'successfully' do
        bottom = instance_double(
          'ClassUse', not_top_of_stack: false, name: 'Bottom', stack_level: 23,
                      add_callee: []
        )
        callers_stack = [
          instance_double(
            'ClassUse', not_top_of_stack: false, name: 'Top', stack_level: 25,
                        add_callee: []
          ),
          instance_double(
            'ClassUse', not_top_of_stack: false, name: 'Mid', stack_level: 24,
                        add_callee: []
          ),
          bottom
        ]
        caller_stub = double(length: 24)
        processor = setup_processor_with_state([], 25, callers_stack)
        trace_point = instance_double(
          'TracePoint', defined_class: 'Simple', callee_id: 'do_it',
                        path: '/path/to/simple', lineno: 87,
                        self: Simple, event: :call
        )
        allow(processor).to receive(:caller).and_return(caller_stub)
        processor.process_event(trace_point)
        classes_names = processor.classes_uses.map(&:name)
        callers_stack = processor
                        .instance_variable_get(:@callers_stack)
                        .map(&:name)

        expect(classes_names).to eq %w[Top Mid]
        expect(callers_stack).to eq %w[Simple Bottom]
      end
    end

    context 'when stack level mantains' do
      it 'successfully' do
        bottom = instance_double(
          'ClassUse', not_top_of_stack: false, name: 'Bottom', stack_level: 24,
                      add_callee: []
        )
        callers_stack = [
          bottom
        ]
        caller_stub = double(length: 24)
        processor = setup_processor_with_state([], 24, callers_stack)
        trace_point = double(
          'TracePoint', defined_class: 'Simple', callee_id: 'do_it',
                        path: '/path/to/simple', lineno: 87,
                        self: Simple, event: :call
        )
        allow(processor).to receive(:caller).and_return(caller_stub)

        processor.process_event(trace_point)
        classes_names = processor.classes_uses.map(&:name)
        callers_stack = processor
                        .instance_variable_get(:@callers_stack)
                        .map(&:name)

        expect(classes_names).to eq ['Bottom']
        expect(callers_stack).to eq ['Simple']
      end
    end

    context 'when stack level increases' do
      it 'successfully' do
        bottom = double(
          'ClassUse', not_top_of_stack: false, name: 'Bottom', stack_level: 24,
                      add_callee: []
        )
        callers_stack = [
          bottom
        ]
        caller_stub = double(length: 26)
        processor = setup_processor_with_state([], 24, callers_stack)
        trace_point = double(
          'TracePoint', defined_class: 'Simple', callee_id: 'do_it',
                        path: '/path/to/simple', lineno: 87,
                        self: Simple, event: :call
        )
        allow(processor).to receive(:caller).and_return(caller_stub)

        processor.process_event(trace_point)
        classes_names = processor.classes_uses.map(&:name)
        callers_stack = processor
                        .instance_variable_get(:@callers_stack)
                        .map(&:name)

        expect(classes_names).to eq []
        expect(callers_stack).to eq %w[Simple Bottom]
      end
    end
  end

  describe '#aggregate_uses' do
    it 'successfully' do
      class_use = double('ClassUse')
      callers = double('ClassUse')
      processor = setup_processor_with_state([class_use], 25, [callers])

      processor.aggregate_uses

      classes_uses = processor.classes_uses
      expect(classes_uses).to include class_use
      expect(classes_uses).to include callers
    end
  end
end
