# frozen_string_literal: true

require 'spec_helper'

describe Trace2::QueryUse do
  describe '#select' do
    it 'successfully for empty query' do
      class_use = instance_double('Trace2::ClassUse')
      classes_uses = [class_use]
      query = Trace2::QueryUse.where([])

      selected_classes = query.select(classes_uses)

      expect(selected_classes).to eq classes_uses
    end

    it 'applies query successfully' do
      class_use = instance_double('Trace2::ClassUse')
      classes_uses = [class_use]
      query = Trace2::QueryUse.where(
        [allow: [{ name: ['RSpec'], path: ['/my/path/to'] }]]
      )

      allow(class_use).to receive(:matches_name?)
        .and_return(true)
      allow(class_use).to receive(:matches_path?)
        .and_return(true)

      selected_classes = query.select(classes_uses)

      expect(selected_classes).to eq classes_uses
    end

    it 'applies AND query successfully' do
      remove_use = instance_double('Trace2::ClassUse')
      allow(remove_use).to receive(:matches_name?).and_return(false)

      accept_use = instance_double('Trace2::ClassUse')
      allow(accept_use).to receive(:matches_name?).and_return(true)
      allow(accept_use).to receive(:matches_path?).and_return(false)

      pass_first_filter = instance_double('Trace2::ClassUse')
      allow(pass_first_filter).to receive(:matches_name?).and_return(true)
      allow(pass_first_filter).to receive(:matches_path?).and_return(true)

      classes_uses = [remove_use, accept_use, pass_first_filter]

      query_parameters = [
        allow: [{ name: ['RSpec'] }],
        reject: [{ path: ['/my/path/to'] }]
      ]

      query = Trace2::QueryUse.where(query_parameters)
      selected_classes = query.select(classes_uses)

      expect(selected_classes).to eq [accept_use]
    end

    it 'applies OR query successfully' do
      fail_query = instance_double('Trace2::ClassUse')
      allow(fail_query).to receive(:matches_name?).and_return(false)
      allow(fail_query).to receive(:matches_path?).and_return(false)

      pass_name = instance_double('Trace2::ClassUse')
      allow(pass_name).to receive(:matches_name?).and_return(true)
      allow(pass_name).to receive(:matches_path?).and_return(false)

      pass_both = instance_double('Trace2::ClassUse')
      allow(pass_both).to receive(:matches_name?).and_return(true)
      allow(pass_both).to receive(:matches_path?).and_return(true)

      classes_uses = [fail_query, pass_name, pass_both]

      query_parameters = [
        allow: [{ name: ['RSpec'] }, { path: ['/my/path/to'] }]
      ]

      query = Trace2::QueryUse.where(query_parameters)
      selected_classes = query.select(classes_uses)

      expect(selected_classes).to eq [pass_name, pass_both]
    end

    it 'applies both types of query' do
      fail_both = instance_double('Trace2::ClassUse')
      allow(fail_both).to receive(:matches_name?).and_return(false)
      allow(fail_both).to receive(:matches_path?).and_return(false)
      allow(fail_both).to receive(:matches_top_of_stack?).and_return(false)

      fail_stack = instance_double('Trace2::ClassUse')
      allow(fail_stack).to receive(:matches_name?).and_return(true)
      allow(fail_stack).to receive(:matches_path?).and_return(true)
      allow(fail_stack).to receive(:matches_top_of_stack?).and_return(false)

      pass_name = instance_double('Trace2::ClassUse')
      allow(pass_name).to receive(:matches_name?).and_return(true)
      allow(pass_name).to receive(:matches_path?).and_return(false)
      allow(pass_name).to receive(:matches_top_of_stack?).and_return(true)

      pass_path = instance_double('Trace2::ClassUse')
      allow(pass_path).to receive(:matches_name?).and_return(false)
      allow(pass_path).to receive(:matches_path?).and_return(true)
      allow(pass_path).to receive(:matches_top_of_stack?).and_return(true)

      classes_uses = [fail_both, fail_stack, pass_name, pass_path]

      query_parameters = [
        { allow: [{ name: ['RSpec'] }, { path: ['/my/path/to'] }] },
        { allow: [{ top_of_stack: true }] }
      ]

      query = Trace2::QueryUse.where(query_parameters)
      selected_classes = query.select(classes_uses)

      expect(selected_classes).to eq [pass_name, pass_path]
    end
  end

  describe '#filter' do
    it 'successfully for empty query' do
      class_use = instance_double('Trace2::ClassUse')
      query = Trace2::QueryUse.where([])

      selected_classes = query.filter(class_use)

      expect(selected_classes).to eq class_use
    end

    it 'applies query successfully' do
      class_use = instance_double('Trace2::ClassUse')
      query = Trace2::QueryUse.where(
        [
          allow: [
            { name: ['RSpec'], path: ['/my/path/to'] }
          ]
        ]
      )

      allow(class_use).to receive(:matches_name?)
        .and_return(false)
      allow(class_use).to receive(:matches_path?)
        .and_return(true)

      selected_classes = query.filter(class_use)

      expect(selected_classes).to be_nil
    end

    it 'applies a complex filter successfully' do
      filters = [
        { allow: [
          { caller_class: { name: [/ForASimpleClass/] } },
          { name: [/ForASimpleClass/] }
        ] },
        {
          allow: [{ top_of_stack: true }]
        }
      ]

      query = Trace2::QueryUse.where(filters)

      pass_path = instance_double('Trace2::ClassUse')
      allow(pass_path).to receive(:matches_caller_class?).and_return(true)
      allow(pass_path).to receive(:matches_name?).and_return(false)
      allow(pass_path).to receive(:matches_top_of_stack?).and_return(false)

      expect(query.filter(pass_path)).to be_nil
    end

    it 'applies a query to direct and indirect callers of class use' do
      query_parameters = [
        { allow: [{ caller_class: { name: ['RSpec'] } }] }
      ]

      second_caller =  Trace2::ClassUse.new(
        name: 'RSpec', caller_class: nil
      )
      first_caller = Trace2::ClassUse.new(
        name: 'YourClass', caller_class: second_caller
      )
      valid_callee = Trace2::ClassUse.new(
        name: 'MyClass', caller_class: first_caller
      )

      allow(first_caller).to receive(:matches_name?).and_return(false)
      allow(second_caller).to receive(:matches_name?).and_return(true)

      query = Trace2::QueryUse.where(query_parameters)
      class_use = query.filter(valid_callee)

      expect(class_use).to eq valid_callee
      expect(first_caller).to have_received(:matches_name?)
      expect(second_caller).to have_received(:matches_name?)
    end
  end
end
