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
      @args = options[:args]
      @executable = options[:executable]
      @output_path = options.fetch(:output_path)
      @executable_runner = options[:executable_runner] || ExecutableRunner.new
      @render_graph_automatically = options.fetch(:automatic_render, false)
      @graph_format = options[:graph_format]
      @filter_path = options[:filter_path]
      @dot_wrapper = options.fetch(:dot_wrapper, DotWrapper.new)
      build_class_lister(options)
    end

    def run
      at_exit { end_class_listing }
      class_lister.enable
      executable_runner.run(executable, args)
    end

    private

    attr_reader :args, :class_lister, :executable, :executable_runner,
                :output_path, :graph_generator, :render_graph_automatically,
                :dot_wrapper

    def build_class_lister(options)
      filter = load_filter
      tools = options.fetch(:reporting_tools_factory, ReportingToolsFactory.new)
                     .build(filter, type: options[:tools_type])

      @class_lister = tools[:class_lister]
      @graph_generator = tools[:graph_generator]
    end

    def load_filter
      return YAML.load_file(@filter_path) if File.exist?(@filter_path)

      []
    end

    def end_class_listing
      class_lister.disable
      graph_generator.run(output_path, class_lister)
      run_graph_rendering
    end

    def run_graph_rendering
      return unless render_graph_automatically

      final_file = "#{output_path}.#{@graph_format}"
      dot_wrapper.render_graph(output_path, final_file, @graph_format)
    end
  end
end
