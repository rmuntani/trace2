# frozen_string_literal: true

module Trace2
  # Base class for trace2's executable
  class Runner
    def self.run(args: ARGV, options: Options.new)
      options_hash = options.parse(args)
      new(options_hash).run
    end

    def initialize(options)
      @class_lister = initialize_class_lister(options)
      @report_generator = options.fetch(:report_generator, GraphGenerator.new)
      @executable = options[:executable]
      @args = options[:args]
      @output_path = options.fetch(:output_path, 'trace2_report.dot')
      @executable_runner = options.fetch(
        :executable_runner, ExecutableRunner.new
      )
    end

    def run
      set_at_exit_callback { end_class_listing }
      class_lister.enable
      executable_runner.run(executable, args)
    end

    private

    attr_reader :args, :class_lister, :executable, :executable_runner,
                :output_path, :report_generator

    def initialize_class_lister(options)
      return options[:class_lister] if options[:class_lister]

      event_processor = options.fetch(:event_processor, EventProcessorC)
      ClassLister.new(event_processor: event_processor)
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
