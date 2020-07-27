# frozen_string_literal: true

module Trace2
  # OptionParser for Trace2's runner. It is uses ruby's
  # default option parser
  class OptionParser
    def self.parse(args)
      new.parse(args)
    end

    def initialize
      @options = {}
      @option_parser = ::OptionParser.new do |opts|
        options_banner(opts)
        help_option(opts)
        version_option(opts)
        filter_option(opts)
        output_option(opts)
      end
    end

    def parse(args)
      @option_parser.parse(args)
      @options
    end

    private

    def options_banner(opts)
      opts.banner = 'Usage: trace2 [options] ' \
       'RUBY_EXECUTABLE [executable options]'
    end

    def help_option(opts)
      opts.on('-h', '--help', 'Display help') do
        puts opts.to_s
        exit_runner
      end
    end

    def version_option(opts)
      opts.on('-v', '--version', 'Show trace2 version') do
        puts VERSION
        exit_runner
      end
    end

    def exit_runner
      exit
    end

    def filter_option(opts)
      opts.on('--filter FILTER_PATH', 'Specify a filter file') do |filter|
        @options[:filter_path] = filter
      end
    end

    def output_option(opts)
      opts.on('-o',
              '--output OUTPUT_PATH',
              'Output path for the report file') do |output|
        @options[:output_path] = output
      end
    end
  end
end
