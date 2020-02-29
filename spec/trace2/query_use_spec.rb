# frozen_string_literal: true

require 'spec_helper'

describe QueryUse do
  describe '.reject' do
    it 'returns QueryUse with classes_uses' do
      classes_uses = [double('ClassUse')]

      query = QueryUse.reject(classes_uses)

      expect(query.classes_uses).to eq classes_uses
    end
  end

  describe '#reject' do
    it 'changes query action' do
      classes_uses = [double('ClassUse')]
      query = QueryUse.new(classes_uses, :select)

      new_query = query.reject

      expect(new_query.instance_variable_get(:@action)).to eq :reject
    end
  end

  describe '.allow' do
    it 'returns QueryUse with classes_uses' do
      classes_uses = [double('ClassUse')]

      query = QueryUse.allow(classes_uses)

      expect(query.classes_uses).to eq classes_uses
    end
  end

  describe '#allow' do
    it 'changes query action' do
      classes_uses = [double('ClassUse')]
      query = QueryUse.new(classes_uses, :select)

      new_query = query.allow

      expect(new_query.instance_variable_get(:@action)).to eq :select
    end
  end

  describe '#where' do
    it 'calls methods depending on input hash keys' do
      class_use = double('ClassUse')
      classes_uses = [class_use]
      query = QueryUse.reject(classes_uses)
      hash = { name: 'my_class' }

      expect(class_use).to receive(:matches_name?).with('my_class')
      query.where(hash)
    end

    it 'returns the query as result' do
      class_use = double('ClassUse', path: 'my_path')
      classes_uses = [class_use]
      query = QueryUse.allow(classes_uses)
      hash = { path: ['my_path'] }

      allow(class_use).to receive(:matches_path?).and_return true
      query_output = query.where(hash)

      expect(query_output).to eq query
    end
  end
end
