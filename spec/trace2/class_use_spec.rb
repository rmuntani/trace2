# frozen_string_literal: true

require 'spec_helper'

describe ClassUse do
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
