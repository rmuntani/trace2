# frozen_string_literal: true

require 'spec_helper'

describe ClassUse do
  describe '#build' do
    it 'build the class use from a TracePoint' do
      trace_point = double(
        'TracePoint',
        defined_class: 'MyClass',
        callee_id: 'do_something'
      )
      call_stack = ['path/file.rb:5:in `do_something\'']

      class_use = ClassUse.build(trace_point, call_stack, nil)

      expect(class_use.name).to eq 'MyClass'
      expect(class_use.method).to eq 'do_something'
      expect(class_use.call_stack).to eq call_stack
    end

    it 'build the class with its caller' do
      trace_point = double(
        'TracePoint',
        defined_class: 'MyClass',
        callee_id: 'do_something'
      )
      caller_class = double('ClassUse',
                            name: 'CallerClass',
                            method: :caller_method)
      possible_callers = [caller_class]
      call_stack = [
        "/path/trace2/spec/trace2/class_listing_spec.rb:5:in `simple_call'",
        "/path/trace2/spec/trace2/class_listing_spec.rb:27:in `caller_method'",
        '/path/trace2/spec/trace2/class_listing_spec.rb:89:in'\
        " `block (4 levels) in <top (required)>'"
      ]

      class_use = ClassUse.build(trace_point, call_stack, possible_callers)

      expect(class_use.name).to eq 'MyClass'
      expect(class_use.method).to eq 'do_something'
      expect(class_use.call_stack).to eq call_stack
      expect(class_use.caller_name).to eq 'CallerClass'
    end
  end
end
