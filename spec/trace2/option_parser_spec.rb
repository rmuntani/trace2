# frozen_string_literal: true

require 'spec_helper'

describe Trace2::OptionParser do
  describe '#add_option' do
    subject(:add_option) do
      trace2_parser.add_option(short: short,
                               long: long,
                               description: description)
    end

    let(:trace2_parser) { described_class.new }

    context 'when option has no arguments' do
      let(:short) { '-h' }
      let(:long) { '--help' }
      let(:description) { 'great help' }

      before do
        allow(trace2_parser).to receive(:on)
          .and_return(true)

        add_option
      end

      it 'adds the option key to the options keys' do
        expect(trace2_parser.options_keys).to eq(
          '-h': false,
          '--help': false
        )
      end

      it 'calls the option parser\'s on method' do
        expect(trace2_parser).to have_received(:on)
          .with('-h', '--help', 'great help')
      end
    end

    context 'when option has arguments' do
      let(:short) { '-f FILE' }
      let(:long) { '--file FILE' }
      let(:description) { ['great help', 'helper'] }

      before do
        allow(trace2_parser).to receive(:on)
          .and_return(true)

        add_option
      end

      it 'adds the option key to the options keys' do
        expect(trace2_parser.options_keys).to eq(
          '-f': true,
          '--file': true
        )
      end

      it 'calls the option parser\'s on method' do
        expect(trace2_parser).to have_received(:on)
          .with('-f FILE', '--file FILE', 'great help', 'helper')
      end
    end
  end

  describe '#split_executables' do
    subject(:split_executables) do
      trace2_parser.add_option(short: '-h')
      trace2_parser.add_option(short: '-f FILE', long: '--file FILE')
      trace2_parser.split_executables(args)
    end

    let(:trace2_parser) { described_class.new }

    context 'when args have no options' do
      let(:args) { %w[rspec] }

      it { expect(split_executables).to eq [[], ['rspec']] }
    end

    context 'when args have options that take no arguments' do
      let(:args) { %w[-h rspec -h] }

      it { expect(split_executables).to eq [['-h'], ['rspec', '-h']] }
    end

    context 'when args have options that take arguments' do
      let(:args) { %w[--file /path/there rspec -h] }

      it 'splits the executable' do
        expect(split_executables).to eq(
          [['--file', '/path/there'], ['rspec', '-h']]
        )
      end
    end

    context 'when args have both types of options' do
      let(:args) { %w[--file /path/there -h rspec --fail-fast --tag TAG] }
      let(:expected_split) do
        [
          ['--file', '/path/there', '-h'],
          ['rspec', '--fail-fast', '--tag', 'TAG']
        ]
      end

      it 'splits the executables' do
        expect(split_executables).to eq(expected_split)
      end
    end
  end
end
