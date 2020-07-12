# frozen_string_literal: true

require 'spec_helper'

describe Trace2::GraphGenerator do
  describe '#call' do
    it 'does not raise an error' do
      expect { Trace2::GraphGenerator }.not_to raise_error
    end
  end
end
