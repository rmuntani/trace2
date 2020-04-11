# frozen_string_literal: true

require 'spec_helper'

describe Trace2::RelationshipParser::Mermaid do
  describe '#parse' do
    context 'when there is no callees' do
      it 'generates an empty array' do
        class_use = instance_double(
          'Trace2::ClassUse', callees: [], name: 'NoCallee'
        )

        parsed = Trace2::RelationshipParser::Mermaid.parse([class_use])

        expect(parsed).to eq ''
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

        parsed = Trace2::RelationshipParser::Mermaid.parse([caller_class])

        expect(parsed).to eq "Caller-->First;\n"\
          "Caller-->Second;\n"
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

        parsed = Trace2::RelationshipParser::Mermaid.parse(
          [first_caller, second_caller]
        )

        expect(parsed).to eq "FirstCaller-->FirstCallee;\n"\
          "SecondCaller-->SecondCallee;\n"
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

        parsed = Trace2::RelationshipParser::Mermaid.parse([caller_class])

        expect(parsed).to eq "Caller-->FirstCallee;\n"\
          "FirstCallee-->SecondCallee;\n"\
          "SecondCallee-->ThirdCallee;\n"
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

        parsed = Trace2::RelationshipParser::Mermaid.parse(
          [
            first_caller, second_caller
          ]
        )

        expect(parsed).to eq "1_Caller-->1_1_Callee;\n"\
          "2_Caller-->2_1_Callee;\n"\
          "2_Caller-->3_1_Callee;\n"\
          "1_1_Callee-->1_2_Callee;\n"\
          "1_1_Callee-->2_2_Callee;\n"
      end
    end
  end
end