# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ClassUseFactory do
  describe '.build' do
    it 'successfully' do
      trace_point = double(
        'TracePoint',
        defined_class: 'Callee',
        callee_id: 'do_something',
        path: '/file/path',
        lineno: 10,
        event: :call
      )

      caller_class = double(
        'Trace2::ClassUse',
        name: 'Caller'
      )

      class_use = Trace2::ClassUseFactory.build(
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
      expect(class_use.event).to eq :call
    end

    it 'builds for a block' do
      trace_point = double(
        'TracePoint',
        defined_class: nil,
        self: '#<Callee:0x00005608b25a0080>',
        callee_id: 'do_something',
        path: '/file/path',
        lineno: 15,
        event: :b_call
      )

      caller_class = double(
        'Trace2::ClassUse',
        name: 'Caller'
      )

      class_use = Trace2::ClassUseFactory.build(
        trace_point: trace_point,
        caller_class: caller_class,
        stack_level: 39
      )

      expect(class_use.name).to eq 'Callee'
      expect(class_use.event).to eq :b_call
    end
  end

  describe '.class_name' do
    it 'changes nothing for a method call' do
      trace_point = instance_double(
        'TracePoint', event: :call, defined_class: 'MyClass'
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'MyClass'
    end

    it 'parses the class name for a block' do
      trace_point = instance_double(
        'TracePoint',
        event: :b_call,
        defined_class: nil,
        self: '#<MyClass:0x00005608b25a0080>'
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'MyClass'
    end

    it 'returns self if name is not parseable' do
      trace_point = instance_double(
        'TracePoint', event: :b_call, defined_class: nil, self: 'main'
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'main'
    end
  end
end
