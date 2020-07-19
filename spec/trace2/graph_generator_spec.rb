# frozen_string_literal: true

require 'spec_helper'

describe Trace2::GraphGenerator do
  describe '#run' do
    after do
      File.delete('file.txt') if File.exist?('file.txt')
    end

    it 'uses regex on filters' do
      class_lister_args = {
        filter: [{ allow: [{ path: [%r{/spec/fixtures/classes.rb}] }] }],
        event_processor: Trace2::EventProcessorC,
        filter_parser: Trace2::FilterParser
      }
      class_lister = Trace2::ClassLister.new(class_lister_args)
      expected_file = 'digraph {' \
                      "\n\tComplexNesting -> ComplexNesting" \
                      "\n\tComplexNesting -> Simple" \
                      "\n\tComplexNesting -> Nested" \
                      "\n\tNested -> Simple" \
                      "\n}"

      class_lister.enable
      complex_nesting = ComplexNesting.new
      complex_nesting.complex_call
      class_lister.disable

      Trace2::GraphGenerator.new.run('file.txt')

      expect(File.read('file.txt')).to eq(expected_file)
    end
  end
end
