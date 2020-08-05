# frozen_string_literal: true

module Trace2
  # Class that runs the executable whose runtime will be
  # used to analyze the relationship between classes
  class ExecutableRunner
    def initialize(system_path: ENV['PATH'], argv: ARGV)
      @system_path = system_path
      @argv = argv
    end

    def run(executable, args)
      update_argv(args)
      executable_path = find_executable(executable)
      load(executable_path)
    rescue SyntaxError
      raise SyntaxError, "#{executable} is not a valid Ruby script"
    end

    private

    def find_executable(executable)
      possible_paths = @system_path.split(':').unshift('.').map do |path|
        "#{path}/#{executable}"
      end

      executable_path = possible_paths.find do |path|
        File.exist?(path)
      end

      if executable_path.nil?
        raise ArgumentError, "#{executable} does not exist"
      end

      executable_path
    end

    def update_argv(args)
      @argv.clear.concat(args)
    end
  end
end
