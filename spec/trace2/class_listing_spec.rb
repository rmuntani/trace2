require 'spec_helper'

describe ClassListing do 
  class Simple
    def simple_call; end
  end

  class Nested
    def initialize
      @simple = Simple.new
    end

    def nested_call
      @simple.simple_call
    end

    def nested_simple_call; end
  end

  class ComplexNesting
    def initialize
      @simple = Simple.new
      @nested = Nested.new
    end

    def complex_call
      @simple.simple_call
      @nested.nested_call
      complex_simple_call
      @nested.nested_simple_call
    end
    
    private

    def complex_simple_call; end
  end

  describe '#accessed_classes' do 
    context 'for a simple class' do
      it 'lists all acessed classes' do
        class_listing = ClassListing.new
        simple_class = Simple.new
        
        class_listing.enable
        simple_class.simple_call
        class_listing.disable

        expect(class_listing.accessed_classes).to include 'Simple'
      end
    end

    context 'for a class called inside another class' do
      it 'list all accessed classes' do
        class_listing = ClassListing.new
        nested_class_call = Nested.new
        
        class_listing.enable
        nested_class_call.nested_call
        class_listing.disable

        expect(class_listing.accessed_classes).to include('Simple', 'Nested')
      end
    end
  end

  describe '#callers' do
    context 'for a class calling another class' do
      it 'show that the callee was called by the caller' do
        class_listing = ClassListing.new
        nested_class_call = Nested.new

        class_listing.enable
        nested_class_call.nested_call
        class_listing.disable

        callers = class_listing.callers.find { |c| c[:class] == 'Simple' }
        
        expect(callers[:class]).to eq "Simple"
        expect(callers[:caller]).to eq "Nested"
      end
    end

    context 'for multiple calls inside a class' do
      it 'is able to record multiple calls to different classes' do
        class_listing = ClassListing.new
        complex_nesting = ComplexNesting.new

        class_listing.enable
        complex_nesting.complex_call
        class_listing.disable

        callers = class_listing.callers

        simple_calls = callers.select { |c| c[:class] == 'Simple' } 
        simple_callers = simple_calls.map { |c| c[:caller] }
        nested_calls = callers.select { |c| c[:class] == 'Nested' }
        nested_callers = nested_calls.map { |c| c[:caller] }
        complex_calls = callers.select { |c| c[:class] == 'ComplexNesting' }
        complex_callers = complex_calls.map { |c| c[:caller] }

        expect(simple_calls.length).to eq 2 
        expect(simple_callers).to include('Nested', 'ComplexNesting')
                                           
        expect(nested_calls.length).to eq 2
        expect(nested_callers).to include('ComplexNesting')

        expect(complex_calls.length).to eq 2
      end
    end
  end
end
