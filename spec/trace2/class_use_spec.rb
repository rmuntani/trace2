# frozen_string_literal: true

require 'spec_helper'

describe ClassUse do
  describe '#build' do
    it 'successfully' do
      trace_point = double(
        'TracePoint',
        defined_class: 'Callee',
        callee_id: 'do_something',
        path: '/file/path'
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
    end
  end
end
