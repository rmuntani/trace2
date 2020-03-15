# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ClassUse do
  describe '#callers_stack' do
    it 'successfully' do
      class_use = Trace2::ClassUse.new(caller_class: nil)

      expect(class_use.callers_stack).to eq []
    end

    it 'returns callers for a single caller' do
      caller_class = Trace2::ClassUse.new(
        caller_class: nil, name: 'Simple', method: 'simple_call'
      )
      callee_class = Trace2::ClassUse.new(caller_class: caller_class)

      expect(callee_class.callers_stack).to eq [caller_class]
    end

    it 'returns callers for a long stack of callers' do
      first_caller = Trace2::ClassUse.new(
        caller_class: nil, name: 'First', method: 'first_call'
      )
      second_caller = Trace2::ClassUse.new(
        caller_class: first_caller, name: 'Second', method: 'second_call'
      )
      third_caller = Trace2::ClassUse.new(
        caller_class: second_caller, name: 'Third', method: 'third_call'
      )
      callee = Trace2::ClassUse.new(
        caller_class: third_caller, name: 'Callee', method: 'call'
      )

      expect(callee.callers_stack).to eq [
        third_caller, second_caller, first_caller
      ]
    end

    it 'returns callers stack without their callers' do
      first_caller = Trace2::ClassUse.new(
        caller_class: nil, name: 'First', method: 'first_call'
      )
      second_caller = Trace2::ClassUse.new(
        caller_class: first_caller, name: 'Second', method: 'second_call'
      )
      third_caller = Trace2::ClassUse.new(
        caller_class: second_caller, name: 'Third', method: 'third_call'
      )
      callee = Trace2::ClassUse.new(
        caller_class: third_caller, name: 'Callee', method: 'call'
      )

      compact_callers = callee.callers_stack(compact: true)
      callers_names = compact_callers.map(&:name)
      callers_callers = compact_callers.map(&:caller_class)

      expect(callers_names).to eq %w[Third Second First]
      expect(callers_callers).to eq [nil, nil, nil]
    end

    it 'removes caller using a filter' do
      first_caller = Trace2::ClassUse.new(
        caller_class: nil, name: 'First', method: 'first_call'
      )
      second_caller = Trace2::ClassUse.new(
        caller_class: first_caller, name: 'Second', method: 'second_call'
      )
      third_caller = Trace2::ClassUse.new(
        caller_class: second_caller, name: 'Third', method: 'third_call'
      )
      callee = Trace2::ClassUse.new(
        caller_class: third_caller, name: 'Callee', method: 'call'
      )

      selector = Class.new do
        def filter(class_use)
          class_use unless class_use.name == 'Second'
        end
      end.new

      filtered_callers = callee.callers_stack(selector: selector)
      callers_names = filtered_callers.map(&:name)

      expect(callers_names).to eq %w[Third First]
    end

    it 'applies multiple options' do
      first_caller = Trace2::ClassUse.new(
        caller_class: nil, name: 'First', method: 'first_call'
      )
      second_caller = Trace2::ClassUse.new(
        caller_class: first_caller, name: 'Second', method: 'second_call'
      )
      third_caller = Trace2::ClassUse.new(
        caller_class: second_caller, name: 'Third', method: 'third_call'
      )
      callee = Trace2::ClassUse.new(
        caller_class: third_caller, name: 'Callee', method: 'call'
      )

      selector = Class.new do
        def filter(class_use)
          class_use unless class_use.name == 'Second'
        end
      end.new

      callers = callee.callers_stack(selector: selector, compact: true)
      callers_names = callers.map(&:name)
      callers_callers = callers.map(&:caller_class)

      expect(callers_names).to eq %w[Third First]
      expect(callers_callers).to eq [nil, nil]
    end
  end

  describe '#matches_method?' do
    it 'successfully' do
      class_use = Trace2::ClassUse.new(method: 'it')
      methods = [/hit/, 'it']
      expect(class_use.matches_method?(methods)).to be_truthy
    end
  end

  describe '#matches_name?' do
    it 'successfully' do
      class_use = Trace2::ClassUse.new(name: 'MyTestClass')
      methods = [/MyTest/]
      expect(class_use.matches_name?(methods)).to be_truthy
    end
  end

  describe '#matches_path?' do
    it 'successfully' do
      class_use = Trace2::ClassUse.new(path: 'path/to/my/great_file.rb')
      methods = [/gre.t/]
      expect(class_use.matches_path?(methods)).to be_truthy
    end
  end

  describe '#matches_top_of_stack?' do
    it 'for a class use without callees' do
      class_use = Trace2::ClassUse.new(callees: [])
      is_top = true
      expect(class_use.matches_top_of_stack?(is_top)).to be_truthy
    end

    it 'for a class use without callees' do
      class_use = Trace2::ClassUse.new(
        callees: [
          Trace2::ClassUse.new(callees: [])
        ]
      )
      is_top = true
      expect(class_use.matches_top_of_stack?(is_top)).to be_falsy
    end

    it 'matches a case without callee if is_top is false' do
      class_use = Trace2::ClassUse.new(
        callees: [Trace2::ClassUse.new(caller_class: nil)]
      )
      is_top = false
      expect(class_use.matches_top_of_stack?(is_top)).to be_truthy
    end
  end

  describe '#matches_stack_bottom?' do
    it 'for a class use without callees' do
      class_use = Trace2::ClassUse.new(caller_class: nil)
      is_bottom = true
      expect(class_use.matches_bottom_of_stack?(is_bottom)).to be_truthy
    end

    it 'for a class use without callees' do
      class_use = Trace2::ClassUse.new(
        caller_class: Trace2::ClassUse.new(caller_class: nil)
      )
      is_bottom = true
      expect(class_use.matches_bottom_of_stack?(is_bottom)).to be_falsy
    end

    it 'matches a case with caller if is_bottom is false' do
      class_use = Trace2::ClassUse.new(
        caller_class: Trace2::ClassUse.new(caller_class: nil)
      )
      is_bottom = false
      expect(class_use.matches_bottom_of_stack?(is_bottom)).to be_truthy
    end
  end

  describe '#matches_caller_class?' do
    it 'successfully' do
      caller_use = Trace2::ClassUse.new(name: 'Caller')
      class_use = Trace2::ClassUse.new(caller_class: caller_use)
      caller_attributes = { name: ['Caller'] }

      expect(class_use.matches_caller_class?(caller_attributes)).to be_truthy
    end

    it 'queries an indirect caller using the where format' do
      caller_class = Trace2::ClassUse.new(method: 'it')
      callee_class = Trace2::ClassUse.new(
        method: 'call', caller_class: caller_class
      )
      indirect_callee_class = Trace2::ClassUse.new(
        method: 'super_call', caller_class: callee_class
      )

      caller_attributes = { caller_class: { method: ['it'] } }
      expect(
        indirect_callee_class.matches_caller_class?(caller_attributes)
      ).to be_truthy
    end
  end

  context 'when #matches_something? is not implemented' do
    it 'returns true' do
      class_use = Trace2::ClassUse.new(name: 'Filler')
      caller_attributes = 'anything'

      expect(class_use.matches_something?(caller_attributes)).to be_truthy
    end
  end

  context '#add_callee' do
    it 'successfully' do
      caller_class = Trace2::ClassUse.new(name: 'Caller')
      callee = Trace2::ClassUse.new(name: 'Callee')

      caller_class.add_callee(callee)

      expect(caller_class.callees).to eq [callee]
    end
  end
end
