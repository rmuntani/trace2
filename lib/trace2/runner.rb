# frozen_string_literal: true

module Trace2
  # Base class for trace2's executable
  class Runner
    def self.run(options = {})
      executable = ARGV.shift
      new(options.merge(executable: executable, args: ARGV)).run
    end

    def initialize(options)
      @class_lister = initialize_class_lister(options)
      @system_path = options.fetch(:system_path, ENV['PATH'])
      @report_generator = options.fetch(:report_generator, GraphGenerator.new)
      @executable = options[:executable]
      @output_path = options.fetch(:output_path, 'trace2_report')
      @args = options[:args]
    end

    def run
      executable_path = find_executable
      set_at_exit_callback { generate_report }
      class_lister.enable
      load(executable_path)
    rescue SyntaxError
      raise SyntaxError, "#{executable} is not a valid Ruby script"
    end

    private

    attr_reader :class_lister, :executable, :output_path,
                :report_generator, :system_path

    def initialize_class_lister(options)
      return options[:class_lister] if options[:class_lister]

      event_processor = options.fetch(:event_processor, EventProcessorC)
      ClassLister.new(event_processor: event_processor)
    end

    def find_executable
      possible_paths = system_path.split(':').unshift('.').map do |path|
        "#{path}/#{executable}"
      end

      executable_path = possible_paths.find do |path|
        File.exist?(path)
      end

      raise ArgumentError, 'executable does not exist' if executable_path.nil?

      executable_path
    end

    def set_at_exit_callback
      at_exit do
        yield
      end
    end

    def generate_report
      class_lister.disable
      report_generator.run(output_path)
    end
  end
end
