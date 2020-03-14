# frozen_string_literal: true

require 'spec_helper'

describe ClassesRelationshipParser do
  describe '#parse' do
    context 'when there is no callees' do
      it 'generates an empty array' do
        class_use = instance_double('ClassUse', callees: [], name: 'NoCallee')

        parsed = ClassesRelationshipParser.parse([class_use])

        expect(parsed).to eq []
      end
    end

    context 'when there is only one level of callees' do
      it 'generates an array of hashes with the relationships' do
        first_callee = instance_double('ClassUse', callees: [], name: 'First')
        second_callee = instance_double('ClassUse', callees: [], name: 'Second')
        caller_class = instance_double(
          'ClassUse',
          callees: [first_callee, second_callee],
          name: 'Caller'
        )

        parsed = ClassesRelationshipParser.parse([caller_class])

        expect(parsed).to eq [
          { caller: 'Caller', callee: 'First' },
          { caller: 'Caller', callee: 'Second' }
        ]
      end
    end

    context 'when there are multiple callers and callees with one level' do
      it 'generates an array of hashes with the relationships' do
        first_callee = instance_double(
          'ClassUse', callees: [], name: 'FirstCallee'
        )
        second_callee = instance_double(
          'ClassUse', callees: [], name: 'SecondCallee'
        )

        first_caller = instance_double(
          'ClassUse',
          callees: [first_callee],
          name: 'FirstCaller'
        )
        second_caller = instance_double(
          'ClassUse',
          callees: [second_callee],
          name: 'SecondCaller'
        )

        parsed = ClassesRelationshipParser.parse(
          [first_caller, second_caller]
        )

        expect(parsed).to eq [
          { caller: 'FirstCaller', callee: 'FirstCallee' },
          { caller: 'SecondCaller', callee: 'SecondCallee' }
        ]
      end
    end

    context 'when there are multiple levels with a single callee' do
      it 'generates an array of hashes with the relationships' do
        third_callee = instance_double(
          'ClassUse', callees: [], name: 'ThirdCallee'
        )
        second_callee = instance_double(
          'ClassUse', callees: [third_callee], name: 'SecondCallee'
        )
        first_callee = instance_double(
          'ClassUse', callees: [second_callee], name: 'FirstCallee'
        )
        caller_class = instance_double(
          'ClassUse',
          callees: [first_callee],
          name: 'Caller'
        )

        parsed = ClassesRelationshipParser.parse([caller_class])

        expect(parsed).to eq [
          { caller: 'Caller', callee: 'FirstCallee' },
          { caller: 'FirstCallee', callee: 'SecondCallee' },
          { caller: 'SecondCallee', callee: 'ThirdCallee' }
        ]
      end
    end

    context 'when there are multiple callers and callees with many leves' do
      it 'generates an array of hashes with the relationships' do
        first_second_callee = instance_double(
          'ClassUse', callees: [], name: '1_2_Callee'
        )

        second_second_callee = instance_double(
          'ClassUse', callees: [], name: '2_2_Callee'
        )

        first_first_callee = instance_double(
          'ClassUse',
          callees: [first_second_callee, second_second_callee],
          name: '1_1_Callee'
        )

        second_first_callee = instance_double(
          'ClassUse', callees: [], name: '2_1_Callee'
        )

        third_first_callee = instance_double(
          'ClassUse', callees: [], name: '3_1_Callee'
        )

        first_caller = instance_double(
          'ClassUse', callees: [first_first_callee], name: '1_Caller'
        )

        second_caller = instance_double(
          'ClassUse',
          callees: [second_first_callee, third_first_callee],
          name: '2_Caller'
        )

        parsed = ClassesRelationshipParser.parse([
                                                   first_caller, second_caller
                                                 ])

        expect(parsed).to eq [
          { caller: '1_Caller', callee: '1_1_Callee' },
          { caller: '2_Caller', callee: '2_1_Callee' },
          { caller: '2_Caller', callee: '3_1_Callee' },
          { caller: '1_1_Callee', callee: '1_2_Callee' },
          { caller: '1_1_Callee', callee: '2_2_Callee' }
        ]
      end
    end
  end
end
