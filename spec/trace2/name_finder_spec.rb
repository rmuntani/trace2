# frozen_string_literal: true

require 'spec_helper'

describe Trace2::NameFinder do
  describe '.class_name' do
    subject(:class_name) { described_class.class_name(object) }

    context 'when object is an instance' do
      let(:object) { NormalClass.new }

      it { is_expected.to eq 'NormalClass' }
    end

    context 'when object is a class' do
      let(:object) { NormalClass }

      it { is_expected.to eq 'NormalClass' }
    end

    context 'when object is a module' do
      let(:object) { NormalModule }

      it { is_expected.to eq 'NormalModule' }
    end

    context 'when object raises error on it\'s #to_s' do
      let(:object) { ToSRaisesError }

      it { is_expected.to eq 'ToSRaisesError' }
    end

    context 'when object returns nil as it\'s #to_s' do
      let(:object) { ToSNil }

      it { is_expected.to eq 'ToSNil' }
    end

    context 'when object is inside a module' do
      let(:object) { NormalModule::ClassInside }

      it { is_expected.to eq 'NormalModule::ClassInside' }
    end

    context 'when object is <main>' do
      let(:object) { TOPLEVEL_BINDING.eval('self') }

      it { is_expected.to eq('Object') }
    end

    context 'when object is an anonymous class' do
      let(:object) { Class.new }

      it { is_expected.to eq('AnonymousClass') }
    end

    context 'when object is an anonymous module' do
      let(:object) { Module.new }

      it { is_expected.to eq('AnonymousModule') }
    end
  end
end
