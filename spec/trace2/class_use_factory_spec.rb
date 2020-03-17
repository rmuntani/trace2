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
        self: Simple
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
        self: Simple,
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

  describe '.class_name' do
    it 'parses a module name correctly' do
      module MyModule; end

      trace_point = instance_double(
        'TracePoint',
        event: :b_call,
        defined_class: 'MyModule',
        self: MyModule
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'MyModule'
    end

    it 'parses a class name correctly' do
      class MyClass; end

      trace_point = instance_double(
        'TracePoint',
        event: :b_call,
        defined_class: 'MyClass',
        self: MyClass
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'MyClass'
    end

    it 'parses a class name correctly even when it overrides .to_s' do
      class MyClass
        def self.to_s
          raise 'Name will be parsed anyway'
        end
      end

      trace_point = instance_double(
        'TracePoint',
        event: :b_call,
        defined_class: 'MyClass',
        self: MyClass
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'MyClass'
    end

    it 'parses name correctly even if .to_s returns nil' do
      class MyClass
        def self.to_s
          nil
        end
      end

      trace_point = instance_double(
        'TracePoint',
        event: :b_call,
        defined_class: 'MyClass',
        self: MyClass
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'MyClass'
    end

    it 'returns name correctly for a class instance' do
      class MyClass; end
      class_instance = MyClass.new

      trace_point = instance_double(
        'TracePoint',
        event: :b_call,
        defined_class: 'MyClass',
        self: class_instance
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'MyClass'
    end

    it 'parses <main> class' do
      trace_point = instance_double(
        'TracePoint',
        event: :b_call,
        defined_class: Kernel,
        self: 'main'
      )

      class_name = Trace2::ClassUseFactory.class_name(trace_point)

      expect(class_name).to eq 'Kernel'
    end
  end
end
