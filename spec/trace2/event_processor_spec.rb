# frozen_string_literal: true

require 'spec_helper'

describe Trace2::EventProcessor do
  subject(:processor) do
    described_class.new([], kernel: kernel).tap do |event_processor|
      event_processor.instance_variable_set(:@classes_uses, classes_uses)
      event_processor.instance_variable_set(:@stack_level, stack_level)
      event_processor.instance_variable_set(:@callers_stack, callers_stack)
    end
  end

  let(:kernel) { class_double(Kernel, caller: []) }

  describe '#process_event' do
    let(:classes_uses) { [] }
    let(:trace_point)  do
      instance_double(
        'TracePoint', defined_class: 'Simple', callee_id: 'do_it',
                      path: '/path/to/simple', lineno: 87,
                      self: Simple, event: :call
      )
    end

    context 'when stack level reduces' do
      let(:callers_stack) do
        [
          instance_double(
            'ClassUse', not_top_of_stack: false, name: 'Top', stack_level: 25,
                        add_callee: []
          ),
          instance_double(
            'ClassUse', not_top_of_stack: false, name: 'Mid', stack_level: 24,
                        add_callee: []
          ),
          instance_double(
            'ClassUse', not_top_of_stack: false, name: 'Bottom',
                        stack_level: 23,
                        add_callee: []
          )
        ]
      end
      let(:stack_level) { 25 }

      before do
        caller_stub = instance_double('Array', length: 24)
        allow(kernel).to receive(:caller).and_return(caller_stub)
        processor.process_event(trace_point)
      end

      it('removes from callers stack the classes uses that have stack level '\
          'smaller greater than current level') do
        classes_uses_names = processor.classes_uses.map(&:name)

        expect(classes_uses_names).to eq %w[Top Mid]
      end

      it 'pushes the new use to the callers stack' do
        callers_stack = processor.instance_variable_get(:@callers_stack)
                                 .map(&:name)

        expect(callers_stack).to eq %w[Simple Bottom]
      end
    end

    context 'when stack level maintains' do
      let(:stack_level) { 24 }
      let(:callers_stack) do
        [instance_double(
          'ClassUse', not_top_of_stack: false, name: 'Bottom', stack_level: 24,
                      add_callee: []
        )]
      end

      before do
        caller_stub = instance_double('Array', length: 24)
        allow(kernel).to receive(:caller).and_return(caller_stub)
        processor.process_event(trace_point)
      end

      it('removes from callers stack the classes uses that have stack level '\
          'smaller greater than current level') do
        classes_uses_names = processor.classes_uses.map(&:name)

        expect(classes_uses_names).to eq %w[Bottom]
      end

      it 'pushes the new use to the callers stack' do
        callers_stack = processor.instance_variable_get(:@callers_stack)
                                 .map(&:name)

        expect(callers_stack).to eq %w[Simple]
      end
    end

    context 'when stack level increases' do
      let(:stack_level) { 24 }
      let(:callers_stack) do
        [instance_double(
          'ClassUse', not_top_of_stack: false, name: 'Bottom', stack_level: 24,
                      add_callee: []
        )]
      end

      before do
        caller_stub = instance_double('Array', length: 26)
        allow(kernel).to receive(:caller).and_return(caller_stub)
        processor.process_event(trace_point)
      end

      it('removes from callers stack the classes uses that have stack level '\
          'smaller greater than current level') do
        classes_uses_names = processor.classes_uses.map(&:name)

        expect(classes_uses_names).to be_empty
      end

      it 'pushes the new use to the callers stack' do
        callers_stack = processor.instance_variable_get(:@callers_stack)
                                 .map(&:name)

        expect(callers_stack).to eq %w[Simple Bottom]
      end
    end
  end

  describe '#aggregate_uses' do
    let(:classes_uses) { [instance_double('ClassUse')] }
    let(:callers_stack) { [instance_double('ClassUse')] }
    let(:stack_level) {}

    before do
      processor.aggregate_uses
    end

    it 'concatenates classes uses and callers stack' do
      expect(processor.classes_uses).to eq(callers_stack + classes_uses)
    end
  end
end
