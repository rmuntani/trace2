# frozen_string_literal: true

require 'spec_helper'

shared_examples 'version option' do |args|
  subject(:version_option) { described_class.parse(args) }

  before do
    stub_const('Trace2::VERSION', '1.0.0')
  end

  it 'prints version and exits' do
    expect do
      version_option
    rescue SystemExit
      nil  # implicitly verify that system exits
    end.to output("1.0.0\n").to_stdout
  end
end

shared_examples 'output option' do |args, path|
  subject { described_class.parse(args) }

  it 'returns the output path on the options' do
    expect(subject).to include(output_path: path)
  end
end

shared_examples 'help option' do |args|
  subject(:help_option) { described_class.parse(args) }

  let(:help_banner) do
    <<~HELP
      Usage: trace2 [options] RUBY_EXECUTABLE [executable options]
          -h, --help                       Display help
          -v, --version                    Show trace2 version
              --filter FILTER_PATH         Specify a filter file. Defaults to .trace2.yml
          -o, --output OUTPUT_PATH         Output path for the report file. Defaults to
                                           ./trace2_report.yml
          -t, --type TOOLS_TYPE            Type of the tools that will be used to generate the
                                           relationship between classes. Possible values:
                                           ruby or native. Defaults to native.
              --format FORMAT              Format that will be used to render the relationship's
                                           graph. Has no effect if the manual option is set.
                                           Defaults to pdf.
          -m, --manual                     Don't try to render the relationships graph automatically
    HELP
  end

  it 'prints the help banner and exits' do
    expect do
      help_option
    rescue SystemExit
      nil  # implicitly verify that system exits
    end.to output(help_banner).to_stdout
  end
end

shared_examples 'class lister type option' do |args|
  subject(:runner_type) { described_class.new.parse(args) }

  it { expect(runner_type).to include(tools_type: :ruby) }
end

shared_examples 'wrong runner type option' do |args|
  subject(:runner_type) { described_class.new.parse(args) }

  it { expect(runner_type).to include(tools_type: :native) }

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

    it_behaves_like 'version option', %w[-v]
    it_behaves_like 'version option', %w[--version]

    it_behaves_like 'output option', %w[-o /path/to executable], '/path/to'
    it_behaves_like(
      'output option', %w[--output /path/to executable], '/path/to'
    )

    it_behaves_like 'help option', %w[-h]
    it_behaves_like 'help option', %w[--help]

    it_behaves_like 'class lister type option', %w[-t ruby rspec]
    it_behaves_like 'class lister type option', %w[--type ruby rspec]

    it_behaves_like 'manual graph render', %w[--manual rspec]

    context 'when no executable is passed' do
      let(:args) { %w[] }

      it 'raises an error' do
        expect { parsed_option }.to raise_error(
          ArgumentError,
          'an executable or ruby script name must be passed as argument'
        )
      end
    end

    context 'when --filter is passed' do
      let(:args) { %w[--filter /path/to/file.yml executable] }

      it 'returns the file filter path on the options' do
        expect(parsed_option).to include(filter_path: '/path/to/file.yml')
      end
    end

    context 'when --format it passed' do
      let(:args) { %w[--format jpg executable] }

      it 'returns the format that should be used to render the graph' do
        expect(parsed_option).to include(graph_format: 'jpg')
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

    context 'when no options besides the executable are passed' do
      let(:args) { %w[rspec] }
      let(:default_options) do
        {
          tools_type: :native,
          automatic_render: true,
          graph_format: 'pdf',
          output_path: 'trace2_report.dot',
          filter_path: '.trace2.yml'
        }
      end

      it 'returns default values' do
        expect(parsed_option).to include(default_options)
      end
    end
  end
end
