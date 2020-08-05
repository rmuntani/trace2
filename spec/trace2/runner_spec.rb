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

    let(:args) { %w[--fail-fast --output x] }
    let(:event_processor) do
      instance_double(Trace2::EventProcessor)
    end
    let(:executable) { 'rspec' }
    let(:class_lister) do
      instance_double(Trace2::ClassLister, enable: true, disable: true)
    end
    let(:report_generator) do
      instance_double(Trace2::GraphGenerator, run: true)
    end
    let(:executable_runner) do
      instance_double(Trace2::ExecutableRunner, run: true)
    end
    let(:output_path) { '/our/path' }
    let(:executable_path) { 'spec/fixtures/executable' }
    let(:initialization_params) do
      {
        args: args,
        class_lister: class_lister,
        event_processor: event_processor,
        executable: executable,
        executable_runner: executable_runner,
        output_path: output_path,
        report_generator: report_generator
      }
    end
    let(:runner) { described_class.new(initialization_params) }

    before do
      allow(runner).to receive(:set_at_exit_callback)
        .and_yield

      run_runner
    end

    it 'enables class listing' do
      expect(class_lister).to have_received(:enable)
    end

    it 'sets an at_exit callback' do
      expect(runner).to have_received(:set_at_exit_callback)
    end

    it 'calls the executable runner' do
      expect(executable_runner).to have_received(:run)
        .with(executable, args)
    end

    it 'disables class listing' do
      expect(class_lister).to have_received(:disable)
    end

    it 'tries to run a report generator' do
      expect(report_generator).to have_received(:run)
        .with(output_path)
    end
  end
end
