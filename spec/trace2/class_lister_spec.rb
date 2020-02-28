# frozen_string_literal: true

require 'spec_helper'

describe ClassLister do
  describe '#accessed_classes' do
    context 'for a simple class' do
      it 'lists all acessed classes' do
        class_lister = ClassLister.new
        simple_class = Simple.new

        class_lister.enable
        simple_class.simple_call
        class_lister.disable

        expect(class_lister.accessed_classes_names).to include 'Simple'
      end
    end

    context 'for a class called inside another class' do
      it 'lists all accessed classes' do
        class_lister = ClassLister.new
        nested_class_call = Nested.new

        class_lister.enable
        nested_class_call.nested_call
        class_lister.disable

        classes_names = class_lister.accessed_classes_names

        expect(classes_names).to include('Simple', 'Nested')
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

      it 'marks the top of a stack' do
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

        expect(simple_class.top_of_stack).to be_truthy
        expect(nested_class.top_of_stack).to be_falsy
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
  end
end
