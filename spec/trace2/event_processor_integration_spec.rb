# frozen_string_literal: true

require 'spec_helper'

describe Trace2::EventProcessor do
  subject(:class_lister) do
    Trace2::ClassListerBuilder.new
                              .build(filter, type: :ruby)
  end

  context 'when a simple class is used' do
    let(:filter) { [] }
    let(:simple_use) do
      class_lister.classes_uses
                  .find { |class_use| class_use.name == 'Simple' }
    end

    before do
      simple_class = Simple.new

      class_lister.enable
      simple_class.simple_call
      class_lister.disable
    end

    it 'lists all acessed classes' do
      expect(class_lister.classes_uses.map(&:name)).to include 'Simple'
    end

    it 'lists callees of accessed classes' do
      expect(simple_use.callees).to eq []
    end
  end

  context 'when a class with classes inside is called' do
    let(:filter) { [] }
    let(:simple_class) do
      class_lister.classes_uses
                  .find { |class_use| class_use.name == 'Simple' }
    end
    let(:nested_class) do
      class_lister.classes_uses
                  .find { |class_use| class_use.name == 'Nested' }
    end

    before do
      nested_class_call = Nested.new

      class_lister.enable
      nested_class_call.nested_call
      class_lister.disable
    end

    it 'lists all accessed classes' do
      expect(class_lister.classes_uses.map(&:name)).to include(
        'Simple', 'Nested'
      )
    end

    it 'callee should point to its caller' do
      expect(simple_class.caller_class.name).to eq 'Nested'
    end

    it 'returns an empty array for a class without callees' do
      expect(simple_class.callees).to eq []
    end

    it 'returns an array with the callees for a class with callees' do
      expect(nested_class.callees).to eq [simple_class]
    end
  end

  context 'when a class with multiple levels of nesting is called' do
    let(:filter) { [] }
    let(:classes_uses) { class_lister.classes_uses }

    let(:complex_calls) do
      classes_uses.select { |c| c.name == 'ComplexNesting' }
    end
    let(:complex_callees) do
      complex_calls.map { |use| use.callees.map(&:name) }
    end
    let(:complex_callers) do
      complex_calls.flat_map(&:caller_class).reject(&:nil?).map(&:name)
    end

    let(:nested_calls) { classes_uses.select { |c| c.name == 'Nested' } }
    let(:nested_callees) do
      nested_calls.map { |use| use.callees.map(&:name) }
    end
    let(:nested_callers) do
      nested_calls.flat_map(&:caller_class).map(&:name)
    end

    let(:simple_calls) { classes_uses.select { |c| c.name == 'Simple' } }
    let(:simple_callees) { simple_calls.flat_map(&:callees) }
    let(:simple_callers) { simple_calls.map(&:caller_class).map(&:name) }

    before do
      complex_nesting = ComplexNesting.new

      class_lister.enable
      complex_nesting.complex_call
      class_lister.disable
    end

    it 'registers all callers of the Simple class' do
      expect(simple_callers).to contain_exactly('Nested', 'ComplexNesting')
    end

    it 'registers all callees of the Simple class' do
      expect(simple_callees).to be_empty
    end

    it 'registers all callers of the Nested class' do
      expect(nested_callers).to contain_exactly(
        'ComplexNesting', 'ComplexNesting'
      )
    end

    it 'register all callees of the Nested class' do
      expect(nested_callees).to contain_exactly(['Simple'], [])
    end

    it 'registers all callers of the CompleNesting was called' do
      expect(complex_callers).to contain_exactly('ComplexNesting')
    end

    it 'registers all callees of the CompleNesting was called' do
      expect(complex_callees).to contain_exactly(
        %w[Simple Nested ComplexNesting Nested], []
      )
    end
  end

  context 'when a class with nested functions is called' do
    before do
      nested_functions = NestedFunctions.new

      class_lister.enable
      nested_functions.call
      class_lister.disable
    end

    let(:filter) { [] }
    let(:classes_uses) { class_lister.classes_uses }
    let(:simple_caller) do
      classes_uses.find { |c| c.name == 'Simple' }
                  .caller_class
    end

    it 'connects the callee to the correct caller' do
      expect(simple_caller.name).to eq 'NestedFunctions'
    end

    it 'registers the right function name' do
      expect(simple_caller.method).to eq 'call'
    end
  end

  context 'when a block is yielded' do
    before do
      block_class = BlockUse.new

      class_lister.enable
      block_class.simple_block do
        2 + 2
      end
      class_lister.disable
    end

    let(:filter) { [] }
    let(:classes_uses) { class_lister.classes_uses }
    let(:classes_names) { classes_uses.map(&:name) }

    it 'records the class that yields a block' do
      expect(classes_names).to include 'BlockUse'
    end
  end

  context 'when a filter is used' do
    context 'when filter does not match any class' do
      before do
        simple_class = Simple.new

        class_lister.enable
        simple_class.simple_call
        class_lister.disable
      end

      let(:filter) { [{ allow: [{ name: ['Zaratustra'] }] }] }
      let(:classes_uses) { class_lister.classes_uses }

      it 'returns no results' do
        expect(classes_uses).to be_empty
      end
    end

    context 'when filter matches some classes' do
      before do
        complex_class = ComplexNesting.new

        class_lister.enable
        complex_class.complex_call
        class_lister.disable
      end

      let(:filter) { [{ reject: [{ name: [/Nested/] }] }] }
      let(:classes_uses) { class_lister.classes_uses }

      let(:simple_callers) do
        classes_uses.select { |class_use| class_use.name == 'Simple' }
                    .map(&:caller_class)
                    .map(&:name)
      end
      let(:nested_classes) do
        classes_uses.select { |class_use| class_use.name == 'Nested' }
      end

      let(:complex_uses) do
        classes_uses.select do |class_use|
          class_use.name == 'ComplexNesting'
        end
      end
      let(:complex_callees) do
        complex_uses.map { |use| use.callees.map(&:name) }
      end

      it 'removes classes that are rejected by the filter' do
        expect(nested_classes).to be_empty
      end

      it 'does not list callers that don\'t pass the filter' do
        expect(simple_callers).to eq %w[ComplexNesting ComplexNesting]
      end

      it 'does not list callees that don\'t pass the filter' do
        expect(complex_callees).to contain_exactly(
          [], %w[Simple Simple ComplexNesting]
        )
      end
    end
  end
end
