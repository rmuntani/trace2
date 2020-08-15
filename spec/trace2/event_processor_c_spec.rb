# frozen_string_literal: true

require 'spec_helper'
describe Trace2::EventProcessorC do
  describe '#new' do
    context 'when filter is empty' do
      it 'does not raise an error' do
        expect { described_class.new([]) }.not_to raise_error
      end
    end

    context 'when filter is not empty' do
      it 'does not raise an error' do
        filter = %w[1 1 1 1 validate_name 1 MyClass allow filter]
        expect { described_class.new(filter) }.not_to raise_error
      end
    end
  end

  describe 'validate if functions raise errors' do
    let(:processor) { described_class.new([]) }

    it '#process_event' do
      expect do
        trace_point = TracePoint.trace { |tp| processor.process_event(tp) }
        Simple.new.simple_call
        trace_point.disable
      end.not_to raise_error
    end

    it '#aggregate_uses' do
      expect { processor.aggregate_uses }.not_to raise_error
    end

    it '#classes_uses' do
      expect { processor.classes_uses }.not_to raise_error
    end

    it '#events' do
      expect { processor.events }.not_to raise_error
    end
  end

  describe '#events' do
    it 'returns the needed events for the extension' do
      processor = described_class.new([])

      expect(processor.events).to eq %i[call b_call return b_return]
    end
  end
end
