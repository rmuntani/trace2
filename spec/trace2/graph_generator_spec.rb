# frozen_string_literal: true

require 'spec_helper'

describe Trace2::GraphGenerator do
  subject(:graph_generator) { described_class.new }

  describe '#run' do
    subject(:run_generator) { graph_generator.run(file, class_lister) }

    let(:class_lister) do
      instance_double(Trace2::ClassLister, classes_uses: classes_uses)
    end
    let(:file) { "#{PROJECT_ROOT}/spec/fixtures/graph_sample" }

    after do
      File.delete(file)
    end

    before do
      run_generator
    end

    context 'when there is empty classes uses' do
      let(:classes_uses) { [] }
      let(:expected_file) do
        <<~FILE
          digraph {

          }
        FILE
      end

      it 'generates an empty digraph' do
        expect(File.read(file)).to eq expected_file
      end
    end

    context 'when there is a class use without callers or callees' do
      let(:classes_uses) do
        [
          instance_double(Trace2::ClassUse, name: 'MyClass', caller_class: nil,
                                            callees: [])
        ]
      end
      let(:expected_file) do
        <<~FILE
          digraph {

          }
        FILE
      end

      it 'generates an empty digraph' do
        expect(File.read(file)).to eq expected_file
      end
    end

    context 'when there is a class use with a caller' do
      let(:classes_uses) do
        caller_class = instance_double(Trace2::ClassUse, name: 'Caller')
        [
          instance_double(Trace2::ClassUse, name: 'MyClass',
                                            caller_class: caller_class,
                                            callees: [])
        ]
      end
      let(:expected_file) do
        <<~FILE
          digraph {
            "Caller" -> "MyClass"
          }
        FILE
      end

      it 'generates an empty digraph' do
        expect(File.read(file)).to eq expected_file
      end
    end

    context 'when there is a class use with a callee' do
      let(:classes_uses) do
        callee_class = instance_double(Trace2::ClassUse, name: 'Callee')
        [
          instance_double(Trace2::ClassUse, name: 'MyClass',
                                            caller_class: nil,
                                            callees: [callee_class])
        ]
      end
      let(:expected_file) do
        <<~FILE
          digraph {
            "MyClass" -> "Callee"
          }
        FILE
      end

      it 'generates an digraph with the correct relationship' do
        expect(File.read(file)).to eq expected_file
      end
    end

    context 'when there is a class use with repeated relationships' do
      let(:classes_uses) do
        callee_class = instance_double(Trace2::ClassUse, name: 'Callee')
        callees = [callee_class, callee_class]
        [
          instance_double(Trace2::ClassUse, name: 'MyClass',
                                            caller_class: nil,
                                            callees: callees)
        ]
      end
      let(:expected_file) do
        <<~FILE
          digraph {
            "MyClass" -> "Callee"
          }
        FILE
      end

      it 'generates an digraph without duplicate relationships' do
        expect(File.read(file)).to eq expected_file
      end
    end

    context 'when there is a class use with callers and callees' do
      let(:classes_uses) do
        callee_class = instance_double(Trace2::ClassUse, name: 'Callee')
        caller_class = instance_double(Trace2::ClassUse, name: 'Caller')
        callees = [callee_class, callee_class]
        [
          instance_double(Trace2::ClassUse, name: 'MyClass',
                                            caller_class: caller_class,
                                            callees: callees)
        ]
      end
      let(:expected_file) do
        <<~FILE
          digraph {
            "Caller" -> "MyClass"
            "MyClass" -> "Callee"
          }
        FILE
      end

      it 'generates an digraph with all the relationships' do
        expect(File.read(file)).to eq expected_file
      end
    end

    context 'when there is more than one class use' do
      let(:classes_uses) do
        callee_class = instance_double(Trace2::ClassUse, name: 'Callee')
        snd_callee = instance_double(Trace2::ClassUse, name: 'SecondCallee')

        caller_class = instance_double(Trace2::ClassUse, name: 'Caller')
        snd_caller = instance_double(Trace2::ClassUse, name: 'SecondCaller')

        fst_callees = [callee_class]
        snd_callees = [callee_class, snd_callee]
        [
          instance_double(Trace2::ClassUse, name: 'FirtClass',
                                            caller_class: caller_class,
                                            callees: fst_callees),
          instance_double(Trace2::ClassUse, name: 'SecondClass',
                                            caller_class: snd_caller,
                                            callees: snd_callees)
        ]
      end
      let(:expected_file) do
        <<~FILE
          digraph {
            "Caller" -> "FirtClass"
            "FirtClass" -> "Callee"
            "SecondCaller" -> "SecondClass"
            "SecondClass" -> "Callee"
            "SecondClass" -> "SecondCallee"
          }
        FILE
      end

      it 'generates an digraph with all the relationships' do
        expect(File.read(file)).to eq expected_file
      end
    end
  end
end
