# frozen_string_literal: true

require 'spec_helper'

describe Trace2::OptionParser do
  describe '#add_option' do
    let(:trace2_parser) { described_class.new }

    subject do
      trace2_parser.add_option(short: short,
                               long: long,
                               description: description)
    end

    context 'when option has no arguments' do
      let(:short) { '-h' }
      let(:long) { '--help' }
      let(:description) { 'great help' }

      before do
        allow(trace2_parser).to receive(:on)
          .and_return(true)

        subject
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
      let(:description) { 'great help' }

      before do
        allow(trace2_parser).to receive(:on)
          .and_return(true)

        subject
      end

      it 'adds the option key to the options keys' do
        expect(trace2_parser.options_keys).to eq(
          '-f': true,
          '--file': true
        )
      end

      it 'calls the option parser\'s on method' do
        expect(trace2_parser).to have_received(:on)
          .with('-f FILE', '--file FILE', 'great help')
      end
    end
  end

  describe '#split_executables' do
    let(:trace2_parser) { described_class.new }

    subject do
      trace2_parser.add_option(short: '-h')
      trace2_parser.add_option(short: '-f FILE', long: '--file FILE')
      trace2_parser.split_executables(args)
    end

    context 'when args have no options' do
      let(:args) { %w[rspec] }

      it { expect(subject).to eq [[], ['rspec']] }
    end

    context 'when args have options that take no arguments' do
      let(:args) { %w[-h rspec -h] }

      it { expect(subject).to eq [['-h'], ['rspec', '-h']] }
    end

    context 'when args have options that take arguments' do
      let(:args) { %w[--file /path/there rspec -h] }

      it { expect(subject).to eq [['--file', '/path/there'], ['rspec', '-h']] }
    end

    context 'when args have both types of options' do
      let(:args) { %w[--file /path/there -h rspec --fail-fast --tag TAG] }

      it 'splits the executables' do
        expect(subject).to eq([
                                ['--file', '/path/there', '-h'],
                                ['rspec', '--fail-fast', '--tag', 'TAG']
                              ])
      end
    end

    context 'when there is no executable' do
      let(:args) { %w[-h] }

      it 'raises an error' do
        expect { subject }.to raise_error(
          ArgumentError,
          'an executable or ruby script name must be passed as argument'
        )
      end
    end
  end
end
