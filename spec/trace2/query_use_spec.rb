# frozen_string_literal: true

require 'spec_helper'

describe Trace2::QueryUse do
  describe '#select' do
    subject(:select) do
      described_class.where(filter)
                     .select(classes_uses)
    end

    context 'when query is empty' do
      let(:filter) { [] }
      let(:classes_uses) { [instance_double('Trace2::ClassUse')] }

      it { is_expected.to eq classes_uses }
    end

    context 'when query has one statement and one value' do
      let(:filter) do
        [{ allow: [{ name: ['RSpec'] }] }]
      end

      let(:first_use) do
        instance_double('Trace2::ClassUse', matches_name?: true)
      end

      let(:classes_uses) do
        second_use = instance_double('Trace2::ClassUse', matches_name?: false)
        [first_use, second_use]
      end

      it { is_expected.to eq([first_use]) }
    end

    context 'when a query has an AND statement' do
      let(:filter) do
        [{
          allow: [{ name: ['RSpec'] }],
          reject: [{ path: ['/my/path/to'] }]
        }]
      end

      let(:accepted_use) do
        instance_double('Trace2::ClassUse', matches_name?: true,
                                            matches_path?: false)
      end

      let(:classes_uses) do
        fails_first_validation = instance_double(
          'Trace2::ClassUse', matches_name?: false, matches_path?: false
        )
        fails_snd_validaiton = instance_double(
          'Trace2::ClassUse', matches_name?: false, matches_path?: true
        )
        [accepted_use, fails_first_validation, fails_snd_validaiton]
      end

      it { is_expected.to eq [accepted_use] }
    end

    context 'when a query has an OR statement' do
      let(:filter) do
        [{
          allow: [{ name: ['RSpec'] }, { path: ['/my/path/to'] }]
        }]
      end

      let(:accepted_uses) do
        [
          instance_double(
            'Trace2:ClassUse', matches_name?: true, matches_path?: false
          ),
          instance_double(
            'Trace2:ClassUse', matches_name?: false, matches_path?: true
          )
        ]
      end

      let(:classes_uses) do
        accepted_uses +
          [instance_double(
            'Trace2::ClassUse', matches_name?: false, matches_path?: false
          )]
      end

      it { is_expected.to eq(accepted_uses) }
    end

    context 'when both AND and OR are used on a single filter' do
      let(:filter) do
        [
          { allow: [{ name: ['RSpec'] }, { path: ['/my/path/to'] }] },
          { allow: [{ top_of_stack: true }] }
        ]
      end

      let(:accepted_uses) do
        [
          instance_double('Trace2::ClassUse', matches_name?: true,
                                              matches_path?: false,
                                              matches_top_of_stack?: true),
          instance_double('Trace2::ClassUse', matches_name?: false,
                                              matches_path?: true,
                                              matches_top_of_stack?: true)
        ]
      end

      let(:rejected_uses) do
        [
          instance_double('Trace2::ClassUse', matches_name?: true,
                                              matches_path?: true,
                                              matches_top_of_stack?: false),
          instance_double('Trace2::ClassUse', matches_name?: false,
                                              matches_path?: false,
                                              matches_top_of_stack?: false)
        ]
      end

      let(:classes_uses) do
        accepted_uses + rejected_uses
      end

      it { is_expected.to eq accepted_uses }
    end
  end

  describe '#filter' do
    subject(:filter_uses) do
      described_class.where(filter)
                     .filter(class_use)
    end

    context 'when query is empty' do
      let(:filter) { [] }
      let(:class_use) { instance_double('Trace2::ClassUse') }

      it { is_expected.to eq class_use }
    end

    context 'when query is has one filter with one validation' do
      let(:filter) do
        [
          allow: [
            { name: ['RSpec'] }
          ]
        ]
      end
      let(:class_use) do
        instance_double('Trace2::ClassUse', matches_name?: false)
      end

      it { is_expected.to be_nil }
    end

    context 'when multiple filters with validations is used' do
      let(:filter) do
        [
          { allow: [
            { caller_class: { name: [/ForASimpleClass/] } },
            { name: [/ForASimpleClass/] }
          ] },
          {
            allow: [{ top_of_stack: true }]
          }
        ]
      end
      let(:class_use) do
        instance_double('Trace2::ClassUse', matches_caller_class?: true,
                                            matches_name?: false,
                                            matches_top_of_stack?: false)
      end

      it { is_expected.to be_nil }
    end

    context 'when query has caller_class validaiton' do
      let(:filter) do
        [
          { allow: [{ caller_class: { name: ['RSpec'] } }] }
        ]
      end

      let(:first_caller) do
        Trace2::ClassUse.new(
          name: 'YourClass', caller_class: second_caller
        )
      end
      let(:second_caller) do
        Trace2::ClassUse.new(
          name: 'RSpec', caller_class: nil
        )
      end
      let(:class_use) do
        Trace2::ClassUse.new(
          name: 'MyClass', caller_class: first_caller
        )
      end

      it { is_expected.to eq class_use }
    end
  end
end
