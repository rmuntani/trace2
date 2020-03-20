# frozen_string_literal: true

module Trace2
  # Parses the arguments inserted to run the the trace2 runner
  class ArgumentsParser
    RUNNER_PARAMS = 2
    RUNNER = 1
    TRACE2_PARAMS = 0
    def self.parse(args)
      params = split_arguments(args)
      {
        runner: parse_runner(params[RUNNER]),
        runner_args: params[RUNNER_PARAMS],
        trace2_args: parse_trace2_args(params[TRACE2_PARAMS])
      }
    end

    class << self
      private

      def split_arguments(args)
        trace_args = []
        while option?(args.first)
          trace_args << args.shift
          trace_args << args.shift
        end
        runner_name = args.shift
        runner_args = args
        [trace_args, runner_name, runner_args]
      end

      def option?(str)
        str[0] == '-'
      end

      def parse_trace2_args(trace2_args)
        trace2_args_parsed = trace2_args.map do |arg|
          arg.sub('-', '')
        end
        Hash[*trace2_args_parsed]
      end

      def parse_runner(runner_name)
        Object.const_get("Trace2::#{camelize(runner_name)}")
      end

      def camelize(name)
        name
          .split('_')
          .map { |word| word.sub(word[0], word[0].upcase) }
          .reduce(:+)
      end
    end
  end
end
