# frozen_string_literal: true

require 'spec_helper'

describe QueryUse do
  describe '#select' do
    it 'successfully for empty query' do
      class_use = double('ClassUse')
      classes_uses = [class_use]
      query = QueryUse.where([])

      selected_classes = query.select(classes_uses)

      expect(selected_classes).to eq classes_uses
    end

    it 'applies query successfully' do
      class_use = double('ClassUse')
      classes_uses = [class_use]
      query = QueryUse.where(
        [allow: { name: ['RSpec'], path: ['/my/path/to'] }]
      )

      allow(class_use).to receive(:matches_name?)
        .and_return(true)
      allow(class_use).to receive(:matches_path?)
        .and_return(true)

      selected_classes = query.select(classes_uses)

      expect(selected_classes).to eq classes_uses
    end

    it 'applies multiple queries successfully' do
      remove_use = double('ClassUse')
      allow(remove_use).to receive(:matches_name?).and_return(false)

      accept_use = double('ClassUse')
      allow(accept_use).to receive(:matches_name?).and_return(true)
      allow(accept_use).to receive(:matches_path?).and_return(false)

      pass_first_filter = double('ClassUse')
      allow(pass_first_filter).to receive(:matches_name?).and_return(true)
      allow(pass_first_filter).to receive(:matches_path?).and_return(true)

      classes_uses = [remove_use, accept_use, pass_first_filter]

      query_parameters = [
        allow: { name: ['RSpec'] },
        reject: { path: ['/my/path/to'] }
      ]

      query = QueryUse.where(query_parameters)
      selected_classes = query.select(classes_uses)

      expect(selected_classes).to eq [accept_use]
    end
  end

  describe '#filter' do
    it 'successfully for empty query' do
      class_use = double('ClassUse')
      query = QueryUse.where([])

      selected_classes = query.filter(class_use)

      expect(selected_classes).to eq class_use
    end

    it 'applies query successfully' do
      class_use = double('ClassUse')
      query = QueryUse.where([
                               allow: { name: ['RSpec'], path: ['/my/path/to'] }
                             ])

      allow(class_use).to receive(:matches_name?)
        .and_return(false)
      allow(class_use).to receive(:matches_path?)
        .and_return(true)

      selected_classes = query.filter(class_use)

      expect(selected_classes).to be_nil
    end
  end
end
