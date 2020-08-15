# frozen_string_literal: true

require 'spec_helper'

describe Trace2::GraphGenerator do
  describe '#run' do
    subject(:run_graph_generator) do
      described_class.new.run('file.txt')
    end

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
      class_lister = Trace2::ClassListerBuilder.new.build(filter, type: :native)

      class_lister.enable
      complex_nesting = ComplexNesting.new
      complex_nesting.complex_call
      class_lister.disable

      run_graph_generator
    end

    it 'uses regex on filters' do
      expect(File.read('file.txt')).to eq(expected_file_content)
    end
  end
end
