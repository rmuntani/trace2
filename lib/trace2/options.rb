# frozen_string_literal: true

module Trace2
  # Defines and returns options for Trace2's runner,
  # given the arguments that were passed
  class Options
    def self.parse(args)
      new.parse(args)
    end

    def initialize(option_parser: Trace2::OptionParser.new, kernel: Kernel)
      @options = default_options
      @kernel = kernel
      @option_parser = option_parser
      options_banner
      help_option
      version_option
      filter_option
      output_option
      type_option
      manual_option
    end

    def parse(args)
      trace2, executable_args = @option_parser.split_executables(args)
      executable = executable_args.shift

      @option_parser.parse(trace2)

      raise_missing_executable if executable.nil?

      @options.merge(executable: executable, args: executable_args)
    end

    private

    def default_options
      {
        tools_type: :native,
        automatic_render: true
      }
    end

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

    def type_option
      tools_type = ['Type of the tools that will be used to generate the ',
                    'relationship between classes. Possible values: ',
                    'ruby or native. Defaults to native.']

      @option_parser.add_option(short: '-t TOOLS_TYPE',
                                description: tools_type,
                                long: '--type TOOLS_TYPE') do |type|
        @options[:tools_type] = type.to_sym
      end
    end

    def manual_option
      run_manually = 'Don\'t try to render the relationships ' \
       'graph automatically'
      @option_parser.add_option(short: '-m',
                                description: run_manually,
                                long: '--manual') do |_type|
        @options[:automatic_render] = false
      end
    end

    def raise_missing_executable
      raise ArgumentError, 'an executable or ruby script name'\
       ' must be passed as argument'
    end

    def exit_runner
      @kernel.exit
    end
  end
end
