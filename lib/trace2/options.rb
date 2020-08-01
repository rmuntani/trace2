# frozen_string_literal: true

module Trace2
  # Defines and returns options for Trace2's runner,
  # given the arguments that were passed
  class Options
    def self.parse(args)
      new.parse(args)
    end

    def initialize(option_parser: Trace2::OptionParser.new)
      @options = {}
      @option_parser = option_parser
      options_banner
      help_option
      version_option
      filter_option
      output_option
    end

    def parse(args)
      trace2, executable_args = @option_parser.split_executables(args)
      executable = executable_args.shift

      @option_parser.parse(trace2)
      @options.merge(executable: executable, args: executable_args)
    end

    private

    def options_banner
      @option_parser.banner = 'Usage: trace2 [options] ' \
       'RUBY_EXECUTABLE [executable options]'
    end

    def help_option
      @option_parser.add_option(short: '-h',
                                long: '--help',
                                description: 'Display help') do
        puts @option_parser.to_s
        exit_runner
      end
    end

    def version_option
      @option_parser.add_option(short: '-v',
                                long: '--version',
                                description: 'Show trace2 version') do
        puts VERSION
        exit_runner
      end
    end

    def filter_option
      @option_parser.add_option(description: 'Specify a filter file',
                                long: '--filter FILTER_PATH') do |filter|
        @options[:filter_path] = filter
      end
    end

    def output_option
      @option_parser.add_option(short: '-o OUTPUT_PATH',
                                description: 'Output path for the report file',
                                long: '--output OUTPUT_PATH') do |output|
        @options[:output_path] = output
      end
    end

    def exit_runner
      exit
    end
  end
end
