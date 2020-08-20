# frozen_string_literal: true

module Trace2
  # A class to abstract the usage of the dot executable
  # that comes with graphviz
  class DotWrapper
    def initialize(kernel: Kernel)
      @kernel = kernel
    end

    def render_graph(input_path, output_path, format)
      return warn_graphviz_not_installed unless graphviz_installed?

      execute_graph_render(input_path, output_path, format)
    end

    private

    DOT_VERSION = 'dot -V'
    DOT_RENDER = 'dot %s -T%s -o %s'

    def graphviz_installed?
      @kernel.system(DOT_VERSION)
    end

    def warn_graphviz_not_installed
      @kernel.puts 'Graphviz is not installed on the system. '\
        'Skipping graph rendering...'

      false
    end

    def execute_graph_render(input_path, output_path, format)
      graph_render_command = format(
        DOT_RENDER, input_path, format, output_path
      )
      @kernel.system(graph_render_command)
    end
  end
end
