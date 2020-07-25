# frozen_string_literal: true

require 'spec_helper'

describe Trace2::Runner do
  describe '#run' do
    let(:event_processor) do
      instance_double(Trace2::EventProcessor)
    end
    let(:class_lister) do
      instance_double(Trace2::ClassLister, enable: true, disable: true)
    end
    let(:system_path) { 'spec/fixtures:/path/to/file' }
    let(:report_generator) do
      instance_double(Trace2::GraphGenerator, run: true)
    end
    let(:output_path) { '/our/path' }
    let(:executable_path) { 'spec/fixtures/executable' }
    let(:initialization_params) do
      {
        args: [],
        class_lister: class_lister,
        event_processor: event_processor,
        executable: executable,
        output_path: output_path,
        report_generator: report_generator,
        system_path: system_path
      }
    end
    let(:runner) { described_class.new(initialization_params) }

    subject do
      runner.run
    end

    context 'when executable exists' do
      let(:executable) { 'executable' }

      context 'when the executable is a valid Ruby script' do
        context 'when the executable is on the system_path' do
          before do
            allow(runner)
              .to receive(:load)
              .with(executable_path)
              .and_return(true)
            allow(runner)
              .to receive(:set_at_exit_callback)
              .and_yield
            subject
          end

          it 'enables class listing' do
            expect(class_lister).to have_received(:enable)
          end

          it 'tries to load the executable' do
            expect(runner).to have_received(:load)
              .with('spec/fixtures/executable')
          end

          it 'sets an at_exit callback' do
            expect(runner).to have_received(:set_at_exit_callback)
          end

          it 'disables class listing' do
            expect(class_lister).to have_received(:disable)
          end

          it 'tries to run a report generator' do
            expect(report_generator).to have_received(:run)
              .with(output_path)
          end
        end

        context 'when the executable is not on the system_path' do
          let(:executable) { 'ruby_file' }

          before do
            allow(File)
              .to receive(:exist?)
              .with('./ruby_file')
              .and_return(true)
            allow(runner)
              .to receive(:load)
              .with('./ruby_file')
              .and_return(true)
            allow(runner)
              .to receive(:set_at_exit_callback)
              .and_yield
            subject
          end

          it 'enables class listing' do
            expect(class_lister).to have_received(:enable)
          end

          it 'tries to load the executable' do
            expect(runner).to have_received(:load)
              .with('./ruby_file')
          end

          it 'sets an at_exit callback' do
            expect(runner).to have_received(:set_at_exit_callback)
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

      context 'when the executable is not a valid Ruby script' do
        before do
          allow(runner)
            .to receive(:set_at_exit_callback)
            .and_yield
          allow(runner)
            .to receive(:load)
            .with(executable_path)
            .and_raise(SyntaxError)
        end

        it 'raises an error that specifies what the file should contain' do
          expect { subject }.to raise_error(
            SyntaxError, 'executable is not a valid Ruby script'
          )
        end
      end
    end

    context 'when executable does not exist' do
      let(:executable) { 'bojangle' }

      it 'raises an error' do
        expect { subject }.to raise_error(
          ArgumentError, 'executable does not exist'
        )
      end
    end
  end
end
