# frozen_string_literal: true

require 'spec_helper'

describe Trace2::DotWrapper do
  subject(:dot_wrapper) do
    described_class.new(kernel: kernel)
  end

  let(:kernel) { class_double(Kernel, puts: true) }

  describe '#render_graph' do
    subject(:format_graph) do
      dot_wrapper.render_graph(input_path, output_path, format)
    end

    let(:input_path) { '/path/from' }
    let(:output_path) { '/path/to' }
    let(:format) { 'pdf' }

    context 'when the system has dot installed' do
      before do
        allow(kernel).to receive(:system)
          .with('dot -V')
          .and_return(false)

        format_graph
      end

      it 'outputs that the system does not have dot' do
        expect(kernel).to have_received(:puts)
          .with(
            'Graphviz is not installed on the system. ' \
            'Skipping graph rendering...'
          )
      end

      it { is_expected.to be_falsy }
    end

    context 'when the system does not have dot installed' do
      before do
        allow(kernel).to receive(:system)
          .with('dot -V')
          .and_return(true)

        allow(kernel).to receive(:system)
          .with('dot /path/from -Tpdf -o /path/to')
          .and_return(false)

        format_graph
      end

      it 'does not output that the system does not have dot' do
        expect(kernel).not_to have_received(:puts)
      end

      it 'runs the build graph visualization format' do
        expect(kernel).to have_received(:system)
          .with('dot /path/from -Tpdf -o /path/to')
      end
    end
  end
end
