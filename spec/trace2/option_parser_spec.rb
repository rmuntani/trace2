# frozen_string_literal: true

require 'spec_helper'

shared_examples 'prints version' do |args|
  subject { described_class.parse(args) }

  before do
    stub_const('Trace2::VERSION', '1.0.0')
    allow_any_instance_of(described_class)
      .to receive(:puts)
      .and_return(true)
    allow_any_instance_of(described_class)
      .to receive(:exit_runner)
      .and_return(true)
  end

  it 'prints the version' do
    expect_any_instance_of(described_class)
      .to receive(:puts)
      .with('1.0.0')

    subject
  end

  it 'exits' do
    expect_any_instance_of(described_class)
      .to receive(:exit_runner)
      .at_least(1).time

    subject
  end
end

shared_examples 'parses output path' do |args, path|
  subject { described_class.parse(args) }

  it 'returns the output path on the options' do
    expect(subject).to eq(output_path: path)
  end
end

shared_examples 'prints help banner' do |args|
  subject { described_class.parse(args) }
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
    allow_any_instance_of(described_class)
      .to receive(:puts)
      .and_return(true)
    allow_any_instance_of(described_class)
      .to receive(:exit_runner)
      .and_return(true)
  end

  it 'prints the help banner' do
    expect_any_instance_of(described_class)
      .to receive(:puts)
      .with(help_banner)

    subject
  end

  it 'exits' do
    expect_any_instance_of(described_class)
      .to receive(:exit_runner)
      .at_least(1).time

    subject
  end
end

describe Trace2::OptionParser do
  describe '.parse' do
    it_behaves_like 'prints version', %w[-v]
    it_behaves_like 'prints version', %w[--version]

    it_behaves_like 'parses output path', %w[-o /path/to], '/path/to'
    it_behaves_like 'parses output path', %w[--output /path/to], '/path/to'

    it_behaves_like 'prints help banner', %w[-h]
    it_behaves_like 'prints help banner', %w[--help]

    subject { described_class.parse(args) }

    context 'when --filter is passed' do
      let(:args) { %w[--filter /path/to/file.yml] }

      it 'returns the file filter file on the options' do
        expect(subject).to eq(filter_path: '/path/to/file.yml')
      end
    end
  end
end
