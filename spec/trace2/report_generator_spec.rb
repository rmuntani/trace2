# frozen_string_literal: true

require 'spec_helper'

describe ReportGenerator do
  describe '#generate' do
    let(:output_file) { 'spec/fixtures/test_report.html' }
    after(:each) do
      File.delete(output_file)
    end

    it 'calls the relationship parser' do
      classes_uses = [instance_double('ClassUse')]
      parsed_relationship = [{ caller: 'Caller', callee: 'Callee' }]
      relationship_parser = class_double(
        'ClassesRelationshipParser',
        parse: parsed_relationship
      )

      report_generator = ReportGenerator.new(
        classes_uses: classes_uses,
        relationship_parser: relationship_parser,
        output_path: output_file
      )

      report_generator.run
      report = File.read(output_file)

      expect(relationship_parser).to have_received(:parse).with(classes_uses)
      expect(report).to include(parsed_relationship.to_json)
    end
  end
end
