# frozen_string_literal: true

require 'spec_helper'

describe Trace2::NameFinder do
  describe '.class_name' do
    it 'parses an instance name' do
      simple = Simple.new

      expect(Trace2::NameFinder.class_name(simple)).to eq 'Simple'
    end

    it 'parses a class name' do
      expect(Trace2::NameFinder.class_name(Simple)).to eq 'Simple'
    end

    it 'parses a module name correctly' do
      module MyModule; end

      expect(
        Trace2::NameFinder.class_name(MyModule)
      ).to eq 'MyModule'
    end

    it 'parses a class name correctly' do
      class MyClass; end

      expect(
        Trace2::NameFinder.class_name(MyClass)
      ).to eq 'MyClass'
    end

    it 'parses a class name correctly even when it overrides .to_s' do
      class MyClass
        def self.to_s
          raise 'Name will be parsed anyway'
        end
      end

      expect(Trace2::NameFinder.class_name(MyClass)).to eq 'MyClass'
    end

    it 'parses name correctly even if .to_s returns nil' do
      class MyClass
        def self.to_s
          nil
        end
      end

      expect(Trace2::NameFinder.class_name(MyClass)).to eq 'MyClass'
    end

    it 'returns name correctly for a class instance' do
      class MyClass; end
      class_instance = MyClass.new

      expect(
        Trace2::NameFinder.class_name(class_instance)
      ).to eq 'MyClass'
    end

    it 'parses a class name that is inside a module' do
      module MyModule; class MyClass; end; end
      class_instance = MyModule::MyClass.new

      expect(
        Trace2::NameFinder.class_name(class_instance)
      ).to eq 'MyModule::MyClass'
    end

    it 'parses <main> class' do
      main = TOPLEVEL_BINDING.eval('self')

      expect(
        Trace2::NameFinder.class_name(main)
      ).to eq 'Object'
    end

    it 'parses anonymous classes' do
      anonymous_class = Class.new

      expect(
        Trace2::NameFinder.class_name(anonymous_class)
      ).to eq 'AnonymousClass'
    end

    it 'parses anonymous modules' do
      anonymous_module = Module.new

      expect(
        Trace2::NameFinder.class_name(anonymous_module)
      ).to eq 'AnonymousModule'
    end
  end
end
