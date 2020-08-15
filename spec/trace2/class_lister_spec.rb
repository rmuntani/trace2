# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ClassLister do
  subject(:new_class_lister) do
    described_class.new(event_processor, trace_point)
  end

  let(:trace_point) { class_double('TracePoint') }
  let(:trace_point_instance) do
    instance_double('TracePoint', enable: true, disable: true)
  end
  let(:event_processor) do
    instance_double('Trace2::EventProcessor', events: [1, 2],
                                              process_event: true,
                                              aggregate_uses: true,
                                              classes_uses: ['classes_uses'])
  end
  let(:args) do
    {
      trace_point: trace_point,
      event_processor: event_processor
    }
  end

  describe '#new' do
    before do
      allow(trace_point).to receive(:new)
        .and_yield(trace_point_instance)

      new_class_lister
    end

    it 'initializes an empty classes uses list' do
      expect(new_class_lister.classes_uses).to be_empty
    end

    it 'initializes TracePoint with the events array' do
      expect(trace_point).to have_received(:new)
        .with(1, 2)
    end

    it 'sets event processor\'s event processing' do
      expect(event_processor).to have_received(:process_event)
        .with(trace_point_instance)
    end
  end

  describe '#enable' do
    subject(:enable_class_lister) do
      new_class_lister.enable
    end

    before do
      allow(trace_point).to receive(:new)
        .and_return(trace_point_instance)

      enable_class_lister
    end

    it 'calls trace point\'s enable' do
      expect(trace_point_instance).to have_received(:enable)
    end
  end

  describe '#disable' do
    subject(:disable_class_lister) do
      new_class_lister.disable
    end

    before do
      allow(trace_point).to receive(:new)
        .and_return(trace_point_instance)

      disable_class_lister
    end

    it 'calls trace point\'s disable' do
      expect(trace_point_instance).to have_received(:disable)
    end

    it 'sets classes_uses to be equal to event processor\'s uses' do
      expect(new_class_lister.classes_uses).to eq ['classes_uses']
    end
  end
end
