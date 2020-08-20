# frozen_string_literal: true

require 'spec_helper'

shared_examples 'version option' do |args|
  subject(:version_option) { described_class.new(kernel: kernel).parse(args) }

  let(:kernel) { class_double(Kernel, exit: true, puts: true) }

  before do
    stub_const('Trace2::VERSION', '1.0.0')
  end

  # RSpec doesn't work as expected if the expectations bellow are separed
  # TODO: separate the expectations
  # rubocop:disable RSpec/MultipleExpectations
  it 'prints the version and exits the runner' do
    expect { version_option }.to output("1.0.0\n").to_stdout
    expect(kernel).to have_received(:exit)
  end
  # rubocop:enable RSpec/MultipleExpectations
end

shared_examples 'output option' do |args, path|
  subject { described_class.parse(args) }

  it 'returns the output path on the options' do
    expect(subject).to include(output_path: path)
  end
end

shared_examples 'help option' do |args|
  subject { described_class.new(kernel: kernel) }

  let(:kernel) { class_double(Kernel, exit: true) }

  let(:help_banner) do
    <<~HELP
      Usage: trace2 [options] RUBY_EXECUTABLE [executable options]
          -h, --help                       Display help
          -v, --version                    Show trace2 version
              --filter FILTER_PATH         Specify a filter file
          -o, --output OUTPUT_PATH         Output path for the report file
          -t, --type EVENT_PROCESSOR_TYPE  Type of the EventProcessor that will be used with ClassLister
          -m, --manual                     Don't try to render the relationships graph automatically
    HELP
  end

  # RSpec doesn't work as expected if the expectations bellow are separed
  # TODO: separate the expectations
  # rubocop:disable RSpec/MultipleExpectations
  it 'prints the help banner and exits' do
    expect { subject.parse(args) }.to output(help_banner).to_stdout

    expect(kernel).to have_received(:exit)
  end
  # rubocop:enable RSpec/MultipleExpectations
end

shared_examples 'class lister type option' do |args|
  subject(:runner_type) { described_class.new.parse(args) }

  it { expect(runner_type).to include(event_processor_type: :ruby) }
end

shared_examples 'wrong runner type option' do |args|
  subject(:runner_type) { described_class.new.parse(args) }

  it { expect(runner_type).to include(event_processor_type: :native) }

  it 'warns that the passed type is not implemented' do
    expect { subject.parse(args) }.to output(
      "Class lister type #{args.last} is not a valid type.\n"
    ).to_stdout
  end
end

shared_examples 'manual graph render' do |args|
  subject(:manual_render) { described_class.new.parse(args) }

  it { expect(manual_render).to include(automatic_render: false) }
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

    it_behaves_like 'class lister type option', %w[-t ruby rspec]
    it_behaves_like 'class lister type option', %w[--type ruby rspec]

    it_behaves_like 'manual graph render', %w[--manual rspec]

    context 'when --filter is passed' do
      let(:args) { %w[--filter /path/to/file.yml executable] }

      it 'returns the file filter file on the options' do
        expect(parsed_option).to include(filter_path: '/path/to/file.yml')
      end
    end

    context 'when executable options are are not offered by trace2' do
      let(:args) { %w[--filter /path/to/file.yml rspec --fail-fast executable] }

      it 'returns a hash with the executable options' do
        expect(parsed_option).to include(
          filter_path: '/path/to/file.yml'
        )
      end
    end

    context 'when executable options are offered by trace2' do
      let(:args) { %w[--filter /path/to/file.yml rspec --help] }

      it 'still parses the options and executable arguments correctly' do
        expect(parsed_option).to include(
          filter_path: '/path/to/file.yml',
          executable: 'rspec',
          args: ['--help']
        )
      end
    end

    context 'when no options besides the executable is passed' do
      let(:args) { %w[rspec] }

      it 'returns default values' do
        expect(parsed_option).to include(
          event_processor_type: :native,
          automatic_render: true
        )
      end
    end
  end
end
