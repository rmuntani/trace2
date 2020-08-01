# frozen_string_literal: true

require 'spec_helper'

shared_examples 'version option' do |args|
  subject { described_class.new }

  before do
    stub_const('Trace2::VERSION', '1.0.0')
  end

  before do
    allow(subject).to receive(:exit_runner)
  end

  it 'prints the version and exits' do
    expect(subject).to receive(:exit_runner)
    expect { subject.parse(args) }.to output("1.0.0\n").to_stdout
  end
end

shared_examples 'output option' do |args, path|
  subject { described_class.parse(args) }

  it 'returns the output path on the options' do
    expect(subject).to include(output_path: path)
  end
end

shared_examples 'help option' do |args|
  subject { described_class.new }

  let(:help_banner) do
    <<~HELP
      Usage: trace2 [options] RUBY_EXECUTABLE [executable options]
          -h, --help                       Display help
          -v, --version                    Show trace2 version
              --filter FILTER_PATH         Specify a filter file
          -o, --output OUTPUT_PATH         Output path for the report file
    HELP
  end

  before do
    allow(subject).to receive(:exit_runner)
  end

  it 'prints the help banner and exits' do
    expect(subject).to receive(:exit_runner)

    expect { subject.parse(args) }.to output(help_banner).to_stdout
  end
end

describe Trace2::Options do
  describe '.parse' do
    subject(:parsed_option) do
      described_class.parse(args)
    end

    it_behaves_like 'version option', %w[-v executable]
    it_behaves_like 'version option', %w[--version executable]

    it_behaves_like 'output option', %w[-o /path/to executable], '/path/to'
    it_behaves_like(
      'output option', %w[--output /path/to executable], '/path/to'
    )

    it_behaves_like 'help option', %w[-h executable]
    it_behaves_like 'help option', %w[--help executable]

    context 'when --filter is passed' do
      let(:args) { %w[--filter /path/to/file.yml executable] }

      it 'returns the file filter file on the options' do
        expect(subject).to include(filter_path: '/path/to/file.yml')
      end
    end

    context 'when options are passed along with an executable' do
      let(:args) { %w[--filter /path/to/file.yml rspec --fail-fast executable] }

      context 'when executable options are not part of option parser' do
        it 'returns a hash with the executable options' do
          expect(subject).to include(
            filter_path: '/path/to/file.yml'
          )
        end
      end

      context 'when executable options are part of option parser' do
        let(:args) { %w[--filter /path/to/file.yml rspec --help] }

        it 'returns a hash with the executable options' do
          expect(subject).to include(
            filter_path: '/path/to/file.yml',
            executable: 'rspec',
            args: ['--help']
          )
        end
      end
    end
  end
end
