# frozen_string_literal: true

require 'spec_helper'

describe ClassUse do
  describe '.build' do
    it 'successfully' do
      trace_point = double(
        'TracePoint',
        defined_class: 'Callee',
        callee_id: 'do_something',
        path: '/file/path',
        lineno: 10
      )

      caller_class = double(
        'ClassUse',
        name: 'Caller'
      )

      class_use = ClassUse.build(
        trace_point: trace_point,
        caller_class: caller_class,
        stack_level: 39
      )

      expect(class_use.name).to eq 'Callee'
      expect(class_use.method).to eq 'do_something'
      expect(class_use.stack_level).to eq 39
      expect(class_use.caller_class.name).to eq 'Caller'
      expect(class_use.path).to eq '/file/path'
      expect(class_use.line).to eq 10
      expect(class_use.top_of_stack).to eq true
    end

    it 'builds for a block' do
      trace_point = double(
        'TracePoint',
        defined_class: nil,
        self: 'Callee',
        callee_id: 'do_something',
        path: '/file/path',
        lineno: 15
      )

      caller_class = double(
        'ClassUse',
        name: 'Caller'
      )

      class_use = ClassUse.build(
        trace_point: trace_point,
        caller_class: caller_class,
        stack_level: 39
      )

      expect(class_use.name).to eq 'Callee'
    end
  end

  describe '#callers_stack' do
    it 'successfully' do
      class_use = ClassUse.new(caller_class: nil)

      expect(class_use.callers_stack).to eq []
    end

    it 'for a single caller' do
      caller_class = ClassUse.new(
        caller_class: nil, name: 'Simple', method: 'simple_call'
      )
      callee_class = ClassUse.new(caller_class: caller_class)

      expect(callee_class.callers_stack).to eq [caller_class]
    end

    it 'for a long stack of callers' do
      first_caller = ClassUse.new(
        caller_class: nil, name: 'First', method: 'first_call'
      )
      second_caller = ClassUse.new(
        caller_class: first_caller, name: 'Second', method: 'second_call'
      )
      third_caller = ClassUse.new(
        caller_class: second_caller, name: 'Third', method: 'third_call'
      )
      callee = ClassUse.new(
        caller_class: third_caller, name: 'Callee', method: 'call'
      )

      expect(callee.callers_stack).to eq [
        third_caller, second_caller, first_caller
      ]
    end
  end
end
