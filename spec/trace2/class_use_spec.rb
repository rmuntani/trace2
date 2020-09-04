# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ClassUse do
  describe '#callers_stack' do
    subject(:callers_stack) do
      described_class.new(caller_class: caller_class)
                     .callers_stack(compact: compact, selector: selector)
    end

    let(:compact) { false }
    let(:selector) {}

    context 'when there are no callers' do
      let(:caller_class) {}

      it { is_expected.to be_empty }
    end

    context 'when callee has no indirect callers' do
      let(:caller_class) do
        described_class.new(
          caller_class: nil, name: 'Simple', method: 'simple_call'
        )
      end

      it { is_expected.to eq [caller_class] }
    end

    context 'when callee has indirect callers and compact is true' do
      let(:compact) { true }

      let(:caller_class) do
        first_caller = described_class.new(
          caller_class: nil, name: 'First', method: 'first_call'
        )
        second_caller = described_class.new(
          caller_class: first_caller, name: 'Second', method: 'second_call'
        )
        third_caller = described_class.new(
          caller_class: second_caller, name: 'Third', method: 'third_call'
        )
        described_class.new(
          caller_class: third_caller, name: 'Callee', method: 'call'
        )
      end

      it 'returns all the callers in order' do
        expect(callers_stack.map(&:name)).to eq %w[Callee Third Second First]
      end

      it 'returns all callers without their callers' do
        expect(callers_stack.map(&:caller_class).compact).to be_empty
      end
    end

    context 'when a selector is passed' do
      let(:selector) do
        Class.new do
          def filter(class_use)
            class_use unless class_use.name == 'Second'
          end
        end.new
      end

      let(:caller_class) do
        first_caller = described_class.new(
          caller_class: nil, name: 'First', method: 'first_call'
        )
        second_caller = described_class.new(
          caller_class: first_caller, name: 'Second', method: 'second_call'
        )
        third_caller = described_class.new(
          caller_class: second_caller, name: 'Third', method: 'third_call'
        )
        described_class.new(
          caller_class: third_caller, name: 'Callee', method: 'call'
        )
      end

      it 'removes callers using the selector' do
        expect(callers_stack.map(&:name)).to eq %w[Callee Third First]
      end
    end
  end

  describe '#matches_method?' do
    it 'successfully' do
      class_use = described_class.new(method: 'it')
      methods = [/hit/, 'it']
      expect(class_use).to be_matches_method(methods)
    end
  end

  describe '#matches_name?' do
    it 'successfully' do
      class_use = described_class.new(name: 'MyTestClass')
      methods = [/MyTest/]
      expect(class_use).to be_matches_name(methods)
    end
  end

  describe '#matches_path?' do
    it 'successfully' do
      class_use = described_class.new(path: 'path/to/my/great_file.rb')
      methods = [/gre.t/]
      expect(class_use).to be_matches_path(methods)
    end
  end

  describe '#matches_top_of_stack?' do
    context 'when class has no callees and expectation is true' do
      it 'returns true' do
        class_use = described_class.new(callees: [])
        is_top = true
        expect(class_use).to be_matches_top_of_stack(is_top)
      end
    end

    context 'when class has callees and expectation is true' do
      it 'returns false' do
        class_use = described_class.new(
          callees: [described_class.new(callees: [])]
        )
        is_top = true
        expect(class_use).not_to be_matches_top_of_stack(is_top)
      end
    end

    context 'when class has callees and expctation is false' do
      it 'returns true' do
        class_use = described_class.new(
          callees: [described_class.new(caller_class: nil)]
        )
        is_top = false
        expect(class_use).to be_matches_top_of_stack(is_top)
      end
    end
  end

  describe '#matches_stack_bottom?' do
    context 'when a class has no caller and expectation is true' do
      it 'returns true' do
        class_use = described_class.new(caller_class: nil)

        is_bottom = true

        expect(class_use).to be_matches_bottom_of_stack(is_bottom)
      end
    end

    context 'when a class has caller and expectation is true' do
      it 'returns false' do
        class_use = described_class.new(
          caller_class: described_class.new(caller_class: nil)
        )

        is_bottom = true

        expect(class_use).not_to be_matches_bottom_of_stack(is_bottom)
      end
    end

    context 'when class has caller and expectation is false' do
      it 'returns true' do
        class_use = described_class.new(
          caller_class: described_class.new(caller_class: nil)
        )
        is_bottom = false
        expect(class_use).to be_matches_bottom_of_stack(is_bottom)
      end
    end
  end

  describe '#matches_caller_class?' do
    let(:indirect_caller) { described_class.new(name: 'Indirect') }
    let(:caller_use) do
      described_class.new(name: 'Caller', caller_class: indirect_caller)
    end
    let(:callee_use) { described_class.new(caller_class: caller_use) }

    it 'checks if the caller class matches filter' do
      caller_attributes = { name: ['Caller'] }

      expect(callee_use).to be_matches_caller_class(caller_attributes)
    end

    it 'queries indirect callers using the where format' do
      caller_attributes = { caller_class: { name: ['Indirect'] } }

      expect(
        callee_use
      ).to be_matches_caller_class(caller_attributes)
    end
  end

  context 'when #matches_something? is not implemented' do
    it 'returns true' do
      class_use = described_class.new(name: 'Filler')
      caller_attributes = 'anything'

      expect(class_use).to be_matches_something(caller_attributes)
    end
  end

  describe '#add_callee' do
    it 'adds a callee to the caller.callees array' do
      caller_class = described_class.new(name: 'Caller')
      callee = described_class.new(name: 'Callee')

      caller_class.add_callee(callee)

      expect(caller_class.callees).to eq [callee]
    end
  end
end
