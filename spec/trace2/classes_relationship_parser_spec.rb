# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ClassesRelationshipParser do
  describe '#parse' do
    context 'when there is no callees' do
      it 'generates an empty array' do
        class_use = instance_double(
          'Trace2::ClassUse', callees: [], name: 'NoCallee'
        )

        parsed = Trace2::ClassesRelationshipParser.parse([class_use])

        expect(parsed).to eq []
      end
    end

    context 'when there is only one level of callees' do
      it 'generates an array of hashes with the relationships' do
        first_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: 'First'
        )
        second_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: 'Second'
        )
        caller_class = instance_double(
          'Trace2::ClassUse',
          callees: [first_callee, second_callee],
          name: 'Caller'
        )

        parsed = Trace2::ClassesRelationshipParser.parse([caller_class])

        expect(parsed).to eq [
          { source: 'Caller', target: 'First' },
          { source: 'Caller', target: 'Second' }
        ]
      end
    end

    context 'when there are multiple callers and callees with one level' do
      it 'generates an array of hashes with the relationships' do
        first_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: 'FirstCallee'
        )
        second_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: 'SecondCallee'
        )

        first_caller = instance_double(
          'Trace2::ClassUse',
          callees: [first_callee],
          name: 'FirstCaller'
        )
        second_caller = instance_double(
          'Trace2::ClassUse',
          callees: [second_callee],
          name: 'SecondCaller'
        )

        parsed = Trace2::ClassesRelationshipParser.parse(
          [first_caller, second_caller]
        )

        expect(parsed).to eq [
          { source: 'FirstCaller', target: 'FirstCallee' },
          { source: 'SecondCaller', target: 'SecondCallee' }
        ]
      end
    end

    context 'when there are multiple levels with a single callee' do
      it 'generates an array of hashes with the relationships' do
        third_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: 'ThirdCallee'
        )
        second_callee = instance_double(
          'Trace2::ClassUse', callees: [third_callee], name: 'SecondCallee'
        )
        first_callee = instance_double(
          'Trace2::ClassUse', callees: [second_callee], name: 'FirstCallee'
        )
        caller_class = instance_double(
          'Trace2::ClassUse',
          callees: [first_callee],
          name: 'Caller'
        )

        parsed = Trace2::ClassesRelationshipParser.parse([caller_class])

        expect(parsed).to eq [
          { source: 'Caller', target: 'FirstCallee' },
          { source: 'FirstCallee', target: 'SecondCallee' },
          { source: 'SecondCallee', target: 'ThirdCallee' }
        ]
      end
    end

    context 'when there are multiple callers and callees with many leves' do
      it 'generates an array of hashes with the relationships' do
        first_second_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: '1_2_Callee'
        )

        second_second_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: '2_2_Callee'
        )

        first_first_callee = instance_double(
          'Trace2::ClassUse',
          callees: [first_second_callee, second_second_callee],
          name: '1_1_Callee'
        )

        second_first_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: '2_1_Callee'
        )

        third_first_callee = instance_double(
          'Trace2::ClassUse', callees: [], name: '3_1_Callee'
        )

        first_caller = instance_double(
          'Trace2::ClassUse', callees: [first_first_callee], name: '1_Caller'
        )

        second_caller = instance_double(
          'Trace2::ClassUse',
          callees: [second_first_callee, third_first_callee],
          name: '2_Caller'
        )

        parsed = Trace2::ClassesRelationshipParser.parse(
          [
            first_caller, second_caller
          ]
        )

        expect(parsed).to eq [
          { source: '1_Caller', target: '1_1_Callee' },
          { source: '2_Caller', target: '2_1_Callee' },
          { source: '2_Caller', target: '3_1_Callee' },
          { source: '1_1_Callee', target: '1_2_Callee' },
          { source: '1_1_Callee', target: '2_2_Callee' }
        ]
      end
    end
  end
end
