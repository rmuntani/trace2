# frozen_string_literal: true

require 'spec_helper'

describe Trace2::GraphGeneratorC do
  describe '#run' do
    let(:filter) do
      [{ allow: [{ path: [%r{/spec/fixtures/classes.rb}] }] }]
    end

    let(:expected_file_content) do
      'digraph {' \
        "\n\t\"ComplexNesting\" -> \"ComplexNesting\"" \
        "\n\t\"ComplexNesting\" -> \"Simple\"" \
        "\n\t\"ComplexNesting\" -> \"Nested\"" \
        "\n\t\"Nested\" -> \"Simple\"" \
        "\n}"
    end

    after do
      File.delete('file.txt') if File.exist?('file.txt')
    end

    before do
      tools = Trace2::ReportingToolsFactory
              .new
              .build(filter, type: :native)

      class_lister = tools[:class_lister]
      graph_generator = tools[:graph_generator]

      class_lister.enable
      complex_nesting = ComplexNesting.new
      complex_nesting.complex_call
      class_lister.disable

      graph_generator.run('file.txt', class_lister)
    end

    it 'uses regex on filters' do
      expect(File.read('file.txt')).to eq(expected_file_content)
    end
  end
end
