# frozen_string_literal: true

module Trace2
  # Generates a report of the relationship between the
  # classes that were used
  class ReportGenerator
    TEMPLATES_FOLDER = 'templates'

    def initialize(classes_uses:, relationship_parser:, output_path:)
      @classes_uses = classes_uses
      @relationship_parser = relationship_parser
      @output_path = output_path
    end

    def run
      parsed_relationships = parse_classes_uses
      report_text = make_report_text(parsed_relationships)
      create_report_file(report_text)
    end

    private

    def parse_classes_uses
      @relationship_parser.parse(@classes_uses)
    end

    def make_report_text(parsed_relationships)
      report_template = File.read(template_path)
      report_template.gsub(
        '<%= parsed_relationships %>', parsed_relationships
      )
    end

    def template_path
      parser_name = @relationship_parser.name.split(':').last.downcase
      "#{TEMPLATES_FOLDER}/#{parser_name}_template.html"
    end

    def create_report_file(report_text)
      report = File.new(@output_path, 'w')
      report.write(report_text)
      report.close
    end
  end
end