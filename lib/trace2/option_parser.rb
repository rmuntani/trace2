# frozen_string_literal: true

module Trace2
  # Class that parses the options that will be used
  # by trace2
  class OptionParser < ::OptionParser
    attr_reader :options_keys

    def initialize(banner = nil, width = 32, indent = ' ' * 4)
      @options_keys = {}
      super(banner, width, indent)
    end

    def add_option(short: nil, long: nil, description: nil)
      @options_keys.merge!(option_hash(short), option_hash(long))
      options = [short, long].compact
      on(*options, description) do |option_value|
        yield option_value
      end
    end

    def split_executables(args)
      second_executable = second_executable_arguments(args)
      raise_missing_executable if second_executable.empty?

      [args.shift(args.length - second_executable.length), second_executable]
    end

    private

    def second_executable_arguments(args)
      argument = false
      args.drop_while do |arg|
        accepts_argument = @options_keys[arg.to_sym]
        if accepts_argument.nil? && !argument
          false
        else
          argument = accepts_argument
          true
        end
      end
    end

    def raise_missing_executable
      raise ArgumentError, 'an executable or ruby script name'\
       ' must be passed as argument'
    end

    def option_hash(option)
      return {} if option.nil?

      arguments = option.split
      option_name = arguments.first
      has_arguments = arguments.length > 1
      { option_name.to_sym => has_arguments }
    end
  end
end
