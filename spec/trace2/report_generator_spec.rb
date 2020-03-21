# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ReportGenerator do
  describe '#generate' do
    let(:output_file) { 'spec/fixtures/test_report.html' }
    after(:each) do
      File.delete(output_file)
    end

    it 'calls the relationship parser' do
      classes_uses = [instance_double('Trace2::ClassUse')]
      parsed_relationship = [{ caller: 'Caller', callee: 'Callee' }]
      relationship_parser = class_double(
        'Trace2::RelationshipParser::Mermaid',
        parse: parsed_relationship.to_json,
        name: 'Trace2::RelationshipParser::Mermaid'
      )

      report_generator = Trace2::ReportGenerator.new(
        classes_uses: classes_uses,
        relationship_parser: relationship_parser,
        output_path: output_file
      )

      report_generator.run
      report = File.read(output_file)

      expect(relationship_parser).to have_received(:parse).with(classes_uses)
      expect(report).to include(parsed_relationship.to_json)
    end

    it 'uses a template depending on parser name' do
      allow(File).to receive(:read).and_return('')
      relationship_parser = class_double(
        'Trace2::RelationshipParser::D3',
        parse: '[]',
        name: 'Trace2::RelationshipParser:D3'
      )
      report_generator = Trace2::ReportGenerator.new(
        relationship_parser: relationship_parser,
        classes_uses: [],
        output_path: output_file
      )

      report_generator.run

      expect(File).to have_received(:read).with('templates/d3_template.html')
    end
  end
end
