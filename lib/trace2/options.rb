# frozen_string_literal: true

module Trace2
  # Defines and returns options for Trace2's runner,
  # given the arguments that were passed
  # rubocop:disable Metrics/ClassLength
  class Options
    def self.parse(args)
      new.parse(args)
    end

    # rubocop:disable Metrics/MethodLength
    def initialize(option_parser: Trace2::OptionParser.new, kernel: Kernel)
      @options = default_options
      @kernel = kernel
      @option_parser = option_parser
      options_banner
      help_option
      version_option
      filter_option
      output_path_option
      type_option
      format_option
      manual_option
    end
    # rubocop:enable Metrics/MethodLength

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
        automatic_render: true,
        graph_format: 'pdf',
        output_path: 'trace2_report.dot',
        filter_path: '.trace2.yml'
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
      filter_description = 'Specify a filter file. Defaults to .trace2.yml'
      @option_parser.add_option(description: filter_description,
                                long: '--filter FILTER_PATH') do |filter|
        @options[:filter_path] = filter
      end
    end

    def output_path_option
      output_path = ['Output path for the report file. Defaults to',
                     './trace2_report.yml']
      @option_parser.add_option(short: '-o OUTPUT_PATH',
                                description: output_path,
                                long: '--output OUTPUT_PATH') do |output|
        @options[:output_path] = output
      end
    end

    def type_option
      tools_type = ['Type of the tools that will be used to generate the',
                    'relationship between classes. Possible values:',
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
                                long: '--manual') do
        @options[:automatic_render] = false
      end
    end

    def format_option
      output_format = ['Format that will be used to render the relationship\'s',
                       'graph. Has no effect if the manual option is set.',
                       'Defaults to pdf.']
      @option_parser.add_option(long: '--format FORMAT',
                                description: output_format) do |format|
        @options[:graph_format] = format
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
  # rubocop:enable Metrics/ClassLength
end
