# frozen_string_literal: true

require 'yaml'

module Trace2
  # Base class for trace2's executable
  class Runner
    def self.run(args: ARGV, options: Options.new)
      options_hash = options.parse(args)
      new(options_hash).run
    end

    def initialize(options)
      @report_generator = options.fetch(:report_generator, GraphGenerator.new)
      @executable = options[:executable]
      @args = options[:args]
      @output_path = options.fetch(:output_path, DEFAULT_OUTPUT_PATH)
      @executable_runner = options.fetch(
        :executable_runner, ExecutableRunner.new
      )
      filter = load_filter(options)
      @class_lister = build_class_lister(options, filter)
    end

    def run
      set_at_exit_callback { end_class_listing }
      class_lister.enable
      executable_runner.run(executable, args)
    end

    private

    DEFAULT_OUTPUT_PATH = 'trace2_report.dot'
    DEFAULT_FILTER_YML = '.trace2.yml'

    attr_reader :args, :class_lister, :executable, :executable_runner,
                :output_path, :report_generator

    def load_filter(options)
      filter_path = options.fetch(:filter_path, DEFAULT_FILTER_YML)
      return YAML.load_file(filter_path) if File.exist?(filter_path)

      []
    end

    def build_class_lister(options, filter)
      options.fetch(:class_lister_builder, ClassListerBuilder.new)
             .build(filter, type: options[:event_processor_type])
    end

    def set_at_exit_callback
      at_exit do
        yield
      end
    end

    def end_class_listing
      class_lister.disable
      report_generator.run(output_path)
    end
  end
end
