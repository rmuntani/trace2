# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ReportingToolsFactory do
  subject(:factory) do
    described_class.new(class_lister: class_lister)
  end

  let(:class_lister) do
    class_double('Trace2::ClassLister', new: class_lister_instance)
  end
  let(:class_lister_instance) { instance_double('Trace2::ClassLister') }

  describe '#build' do
    subject(:factory_build) { factory.build(filter, type: type) }

    let(:filter) { ['filter'] }

    context 'when type is :native' do
      let(:type) { :native }
      let(:native_args) do
        {
          event_processor: event_processor_c,
          filter_parser: filter_parser,
          graph_generator: graph_generator_c
        }
      end
      let(:event_processor_c) do
        class_double(
          'Trace2::EventProcessorC', new: event_processor_c_instance
        )
      end
      let(:event_processor_c_instance) do
        instance_double('Trace2::EventProcessorC')
      end
      let(:filter_parser) do
        instance_double('Trace2::FilterParser', parse: ['parsed_filter'])
      end
      let(:graph_generator_c) do
        instance_double('Trace2::GraphGeneratorC')
      end

      before do
        stub_const('Trace2::NATIVE', native_args)

        factory_build
      end

      it 'tries to parse the filter with FilterParser' do
        expect(filter_parser).to have_received(:parse)
          .with(['filter'])
      end

      it 'initializes event processor with a filter' do
        expect(event_processor_c).to have_received(:new)
          .with(['parsed_filter'])
      end

      it 'initializes class lister with EventProcessorC' do
        expect(class_lister).to have_received(:new)
          .with(event_processor_c_instance)
      end

      it 'retuns a class lister and a graph generator' do
        expect(factory_build).to eq(
          class_lister: class_lister_instance,
          graph_generator: graph_generator_c
        )
      end
    end

    context 'when type is :ruby' do
      let(:type) { :ruby }
      let(:ruby_args) do
        {
          event_processor: event_processor,
          filter_parser: nil,
          graph_generator: graph_generator
        }
      end
      let(:event_processor) do
        class_double(
          'Trace2::EventProcessor', new: event_processor_instance
        )
      end
      let(:event_processor_instance) do
        instance_double('Trace2::EventProcessor')
      end
      let(:graph_generator) do
        instance_double('Trace2::GraphGenerator')
      end

      before do
        stub_const('Trace2::RUBY', ruby_args)

        factory_build
      end

      it 'initializes event processor with a filter' do
        expect(event_processor).to have_received(:new)
          .with(['filter'])
      end

      it 'initializes class lister with EventProcessorC' do
        expect(class_lister).to have_received(:new)
          .with(event_processor_instance)
      end

      it 'retuns a class lister' do
        expect(factory_build).to eq(
          class_lister: class_lister_instance,
          graph_generator: graph_generator
        )
      end
    end
  end
end
