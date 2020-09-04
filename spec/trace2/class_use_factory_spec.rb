# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ClassUseFactory do
  describe '.build' do
    subject(:build_use) do
      described_class.build(trace_point: trace_point,
                            caller_class: caller_class,
                            stack_level: stack_level)
    end

    let(:stack_level) { 39 }
    let(:trace_point) do
      instance_double(
        'TracePoint',
        callee_id: 'do_something',
        path: '/file/path',
        lineno: 10,
        event: :call,
        defined_class: 'Simple',
        self: Simple.new
      )
    end
    let(:caller_class) do
      instance_double(
        'Trace2::ClassUse',
        name: 'Caller'
      )
    end
    let(:expected_attributes) do
      {
        name: 'Simple',
        method: 'do_something',
        stack_level: 39,
        caller_class: caller_class,
        path: '/file/path',
        line: 10,
        event: :call
      }
    end

    it { is_expected.to have_attributes(expected_attributes) }
  end
end
