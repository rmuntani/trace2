# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ExecutableRunner do
  describe '#run' do
    subject(:executable_runner) do
      runner_instance.run(executable, args)
    end

    let(:runner_instance) do
      described_class
        .new(system_path: system_path, argv: argv)
    end
    let(:system_path) { 'spec/fixtures:/path/to/file' }
    let(:argv) { instance_double(Array) }

    before do
      allow(argv).to receive(:clear).and_return(argv)
      allow(argv).to receive(:concat).and_return(argv)

      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:exist?).with(file_path).and_return(true)
    end

    context 'when executable exists on PATH' do
      let(:executable) { 'executable' }
      let(:file_path) { 'spec/fixtures/executable' }
      let(:args) { %w[--fail-fast] }

      before do
        allow(runner_instance).to receive(:load).and_return(true)

        executable_runner
      end

      it 'tries to load the executable' do
        expect(runner_instance).to have_received(:load)
          .with('spec/fixtures/executable')
      end

      it 'clears current ARGV' do
        expect(argv).to have_received(:clear)
      end

      it 'inserts arguments into ARGV' do
        expect(argv).to have_received(:concat)
          .with(args)
      end
    end

    context 'when executable is a ruby file' do
      let(:executable) { 'ruby_file' }
      let(:file_path) { './ruby_file' }
      let(:args) { %w[--format d] }

      before do
        allow(runner_instance).to receive(:load).and_return(true)

        executable_runner
      end

      it 'tries to load the executable' do
        expect(runner_instance).to have_received(:load)
          .with('./ruby_file')
      end

      it 'clears current ARGV' do
        expect(argv).to have_received(:clear)
      end

      it 'inserts arguments into ARGV' do
        expect(argv).to have_received(:concat)
          .with(args)
      end
    end

    context 'when executable is not a valid ruby file' do
      let(:executable) { 'executable' }
      let(:file_path) { './executable' }
      let(:args) {}

      before do
        allow(runner_instance).to receive(:load).and_raise(SyntaxError)
      end

      it 'raises an error' do
        expect { executable_runner }.to raise_error(
          SyntaxError, 'executable is not a valid Ruby script'
        )
      end
    end

    context 'when executable does not exist' do
      let(:executable) { 'executable' }
      let(:file_path) {}
      let(:args) {}

      it 'raises an error' do
        expect { executable_runner }.to raise_error(
          ArgumentError, 'executable does not exist'
        )
      end
    end
  end
end
