# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ClassUseFactory do
  describe '.build' do
    it 'successfully' do
      trace_point = double(
        'TracePoint',
        callee_id: 'do_something',
        path: '/file/path',
        lineno: 10,
        event: :call,
        defined_class: 'Simple',
        self: Simple.new
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

      expect(class_use.name).to eq 'Simple'
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
        defined_class: 'Simple',
        callee_id: 'do_something',
        path: '/file/path',
        lineno: 15,
        self: Simple.new,
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

      expect(class_use.name).to eq 'Simple'
      expect(class_use.event).to eq :b_call
    end
  end
end
