# frozen_string_literal: true

require 'spec_helper'

describe Trace2::Summarizer do
  describe '#run' do
    it 'does not raise an error' do
      expect do
        Trace2::Summarizer.new.run
      end.not_to raise_error
    end
  end
end
