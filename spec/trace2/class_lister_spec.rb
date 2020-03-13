# frozen_string_literal: true

require 'spec_helper'

describe ClassLister do
  context 'for a simple class' do
    it 'lists all acessed classes' do
      class_lister = ClassLister.new
      simple_class = Simple.new

      class_lister.enable
      simple_class.simple_call
      class_lister.disable

      accessed_classes = class_lister.classes_uses.map(&:name)

      expect(accessed_classes).to include 'Simple'
    end

    it 'lists callees of accessed classes' do
      class_lister = ClassLister.new
      simple_class = Simple.new

      class_lister.enable
      simple_class.simple_call
      class_lister.disable

      simple_use = class_lister
                   .classes_uses
                   .find { |class_use| class_use.name == 'Simple' }

      expect(simple_use.callees).to eq []
    end
  end

  context 'for a class called inside another class' do
    it 'lists all accessed classes' do
      class_lister = ClassLister.new
      nested_class_call = Nested.new

      class_lister.enable
      nested_class_call.nested_call
      class_lister.disable

      accessed_classes = class_lister.classes_uses.map(&:name)

      expect(accessed_classes).to include('Simple', 'Nested')
    end

    it 'callee should point to its caller' do
      class_lister = ClassLister.new
      nested_class_call = Nested.new

      class_lister.enable
      nested_class_call.nested_call
      class_lister.disable

      simple_class = class_lister
                     .classes_uses
                     .find { |class_use| class_use.name == 'Simple' }

      expect(simple_class.caller_class.name).to eq 'Nested'
    end

    it 'relates caller to its callees' do
      class_lister = ClassLister.new
      nested_class_call = Nested.new

      class_lister.enable
      nested_class_call.nested_call
      class_lister.disable

      simple_class = class_lister
                     .classes_uses
                     .find { |class_use| class_use.name == 'Simple' }
      nested_class = class_lister
                     .classes_uses
                     .find { |class_use| class_use.name == 'Nested' }

      expect(simple_class.callees).to eq []
      expect(nested_class.callees).to eq [simple_class]
    end
  end

  context 'for multiple calls inside a class' do
    it 'is able to record multiple calls to different classes' do
      class_lister = ClassLister.new
      complex_nesting = ComplexNesting.new

      class_lister.enable
      complex_nesting.complex_call
      class_lister.disable

      classes_uses = class_lister.classes_uses

      simple_calls = classes_uses.select { |c| c.name == 'Simple' }
      simple_classes_uses = simple_calls.map(&:caller_class).map(&:name)
      nested_calls = classes_uses.select { |c| c.name == 'Nested' }
      nested_classes_uses = nested_calls.map(&:caller_class).map(&:name)
      complex_calls = classes_uses.select { |c| c.name == 'ComplexNesting' }

      expect(simple_calls.length).to eq 2
      expect(simple_classes_uses).to include('Nested', 'ComplexNesting')

      expect(nested_calls.length).to eq 2
      expect(nested_classes_uses).to include('ComplexNesting')

      expect(complex_calls.length).to eq 2
    end

    it 'connects callers to its callees' do
      class_lister = ClassLister.new
      complex_nesting = ComplexNesting.new

      class_lister.enable
      complex_nesting.complex_call
      class_lister.disable

      classes_uses = class_lister.classes_uses

      simple_calls = classes_uses.select { |c| c.name == 'Simple' }
      simple_callees = simple_calls.map(&:callees)

      nested_calls = classes_uses.select { |c| c.name == 'Nested' }
      empty_nested_callees = nested_calls.map(&:callees).select(&:empty?)
      nested_callees = nested_calls.map(&:callees).reject(&:empty?)

      complex_calls = classes_uses.select { |c| c.name == 'ComplexNesting' }
      empty_complex_callees = complex_calls.map(&:callees).select(&:empty?)
      complex_callees = complex_calls.map(&:callees).reject(&:empty?)

      expect(simple_callees).to eq [[], []]

      expect(empty_nested_callees.count).to eq 1
      expect(
        nested_callees.map { |callees| callees.map(&:name) }
      ).to eq [['Simple']]

      expect(empty_complex_callees.count).to eq 1
      expect(
        complex_callees.map { |callees| callees.map(&:name) }
      ).to eq [%w[Simple Nested ComplexNesting Nested]]
    end
  end

  context 'for nested functions' do
    it 'connects the callee to the correct caller' do
      class_lister = ClassLister.new
      nested_functions = NestedFunctions.new

      class_lister.enable
      nested_functions.call
      class_lister.disable

      classes_uses = class_lister.classes_uses

      simple_class = classes_uses.find { |c| c.name == 'Simple' }
      simple_caller = simple_class.caller_class

      expect(simple_caller.name).to eq 'NestedFunctions'
      expect(simple_caller.method).to eq 'call'
    end
  end

  context 'for a block' do
    it 'records the class that owns the block' do
      class_lister = ClassLister.new
      block_class = BlockUse.new

      class_lister.enable
      block_class.simple_block do
        2 + 2
      end
      class_lister.disable

      classes_uses_names = class_lister.classes_uses.map(&:name)

      expect(classes_uses_names).to include 'BlockUse'
    end
  end

  describe 'integration with QueryUse' do
    it 'lists acessed classes that pass the filter' do
      class_lister = ClassLister.new([{ allow: [{ name: ['Zaratustra'] }] }])
      simple_class = Simple.new

      class_lister.enable
      simple_class.simple_call
      class_lister.disable

      classes_uses = class_lister.classes_uses

      expect(classes_uses).to be_empty
    end

    it 'does not list callers that dont pass the filter' do
      class_lister = ClassLister.new([{ reject: [{ name: [/Nested/] }] }])
      complex_class = ComplexNesting.new

      class_lister.enable
      complex_class.complex_call
      class_lister.disable

      classes_uses = class_lister.classes_uses

      simple_callers = classes_uses
                       .select { |class_use| class_use.name == 'Simple' }
                       .map(&:caller_class)
                       .map(&:name)
      nested_classes = classes_uses
                       .select { |class_use| class_use.name == 'Nested' }

      expect(simple_callers).to eq %w[ComplexNesting ComplexNesting]
      expect(nested_classes).to be_empty
    end

    it 'does not list callees that dont pass the filter' do
      class_lister = ClassLister.new([{ reject: [{ name: [/Nested/] }] }])
      complex_class = ComplexNesting.new

      class_lister.enable
      complex_class.complex_call
      class_lister.disable

      classes_uses = class_lister.classes_uses

      complex_callees = classes_uses
                        .select do |class_use|
        class_use.name == 'ComplexNesting'
      end
                        .map(&:callees)

      used_complex_callees = complex_callees.find { |cn| !cn.empty? }

      expect(complex_callees.length).to eq 2
      expect(complex_callees).to include []
      expect(
        used_complex_callees.map(&:name)
      ).to eq %w[Simple Simple ComplexNesting]
    end
  end
end
