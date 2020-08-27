# frozen_string_literal: true

require 'spec_helper'

describe Trace2::Runner do
  describe '.run' do
    subject(:run_runner) do
      described_class.run(args: args, options: options)
    end

    let(:args) { %w[--help rspec --fail-fast] }
    let(:options) { instance_double(Trace2::Options, parse: {}) }
    let(:instance) { instance_double(described_class, run: nil) }

    before do
      allow(described_class).to receive(:new)
        .and_return(instance)

      run_runner
    end

    it { expect(described_class).to have_received(:new) }
    it { expect(instance).to have_received(:run) }
    it { expect(options).to have_received(:parse).with(args) }
  end

  describe '#run' do
    subject(:run_runner) do
      runner.run
    end

    let(:runner) { described_class.new(initialization_params) }

    let(:initialization_params) do
      {
        args: args,
        reporting_tools_factory: reporting_tools_factory,
        event_processor: event_processor,
        executable: executable,
        executable_runner: executable_runner,
        filter_path: filter_path,
        output_path: output_path,
        automatic_render: automatic_render,
        dot_wrapper: dot_wrapper
      }
    end

    let(:args) { %w[--fail-fast --output x] }

    let(:reporting_tools_factory) do
      instance_double(
        Trace2::ReportingToolsFactory,
        build: { class_lister: class_lister,
                 graph_generator: graph_generator }
      )
    end
    let(:class_lister) do
      instance_double(Trace2::ClassLister, enable: true, disable: true)
    end

    let(:event_processor) do
      instance_double(Trace2::EventProcessor)
    end
    let(:executable) { 'rspec' }
    let(:executable_runner) do
      instance_double(Trace2::ExecutableRunner, run: true)
    end

    let(:filter_path) { 'spec/fixtures/trace2.yml' }
    let(:output_path) { '/our/path' }

    let(:graph_generator) do
      instance_double(Trace2::GraphGenerator, run: true)
    end

    let(:dot_wrapper) do
      instance_double(Trace2::DotWrapper, render_graph: true)
    end

    let(:automatic_render) { true }

    before do
      allow(runner).to receive(:at_exit)
        .and_yield

      run_runner
    end

    it 'builds a class listing class' do
      expect(reporting_tools_factory).to have_received(:build)
        .with(['filter'], type: nil)
    end

    it 'enables class listing' do
      expect(class_lister).to have_received(:enable)
    end

    it 'sets an at_exit callback' do
      expect(runner).to have_received(:at_exit)
    end

    it 'calls the executable runner' do
      expect(executable_runner).to have_received(:run)
        .with(executable, args)
    end

    it 'disables class listing' do
      expect(class_lister).to have_received(:disable)
    end

    it 'tries to run the graph generator' do
      expect(graph_generator).to have_received(:run)
        .with(output_path, class_lister)
    end

    context 'when automatic render is true' do
      it 'runs dot wrapper' do
        expect(dot_wrapper).to have_received(:render_graph)
          .with('/our/path', '/our/path.pdf', 'pdf')
      end
    end
  end
end
