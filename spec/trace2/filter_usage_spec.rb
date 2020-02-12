# frozen_string_literal: true

require 'spec_helper'

describe FilterUsage do
  context 'when filter is empty' do
    it 'does not filter anything' do
      call_stack = ['/path/trace2/spec/trace2/class_listing_spec.rb:5:in'\
                    " `simple_call'"]
      class_use = double('ClassUse', call_stack: call_stack)

      filter = FilterUsage.new

      expect(filter.run(class_use)).to eq class_use
    end
  end

  context 'when filter is configured' do
    it 'filters according to file path' do
      call_stack = ['/path/trace2/spec/trace2/class_listing_spec.rb:5:in'\
                    " `simple_call'"]
      class_use = double('ClassUse', call_stack: call_stack)
      filter = FilterUsage.new(path: 'spec/')

      expect(filter.run(class_use)).to eq nil
    end
  end
end
