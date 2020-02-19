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

      caller_class_stack = [
        "/path/trace2/spec/trace2/class_listing_spec.rb:27:in `caller_method'"
      ]
      caller_class = double('ClassUse',
                            name: 'CallerClass',
                            call_stack: caller_class_stack)

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

    it "build the class with its caller, even if caller's method's"\
       ' name appears multiple time' do
      trace_point = double(
        'TracePoint',
        defined_class: 'Simple',
        callee_id: 'simple_call'
      )

      real_caller_stack = ["test.rb:14:in `do_something'"]
      real_caller = double(
        'ClassUse',
        name: 'RealCaller',
        method: :do_something,
        call_stack: real_caller_stack
      )

      false_caller_stack = ["test.rb:15:in `do_something'"]
      false_caller = double(
        'ClassUse',
        name: 'FalseCaller',
        method: :do_something,
        call_stack: false_caller_stack
      )

      call_stack = [
        "test.rb:9:in `simple_call'", "test.rb:14:in `do_something'"
      ]
      possible_callers = [false_caller, real_caller]

      class_use = ClassUse.build(trace_point, call_stack, possible_callers)

      expect(class_use.name).to eq 'Simple'
      expect(class_use.method).to eq 'simple_call'
      expect(class_use.call_stack).to eq call_stack
      expect(class_use.caller_name).to eq 'RealCaller'
    end

    it "builds the class with its caller, even if caller's line changed" do
      trace_point = double(
        'TracePoint',
        defined_class: 'Callee',
        callee_id: 'simple_call'
      )

      caller_stack = ["test.rb:14:in `parent_call'"]
      caller_class = double(
        'ClassUse',
        name: 'Caller',
        method: :parent_call,
        call_stack: caller_stack
      )

      call_stack = [
        "test.rb:9:in `simple_class'", "test.rb:19:in `parent_call'"
      ]
      possible_callers = [caller_class]

      class_use = ClassUse.build(trace_point, call_stack, possible_callers)

      expect(class_use.name).to eq 'Callee'
      expect(class_use.method).to eq 'simple_call'
      expect(class_use.call_stack).to eq call_stack
      expect(class_use.caller_name).to eq 'Caller'
    end
  end
end
