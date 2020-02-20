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
      it 'list all accessed classes' do
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
  end
end
