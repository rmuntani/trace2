require 'spec_helper'

describe ClassListing do 
  context 'for a simple class' do
    let(:simple_class) {
      class Simple
        def call_me; end
      end
      Simple.new
    }
    
    it 'lists all acessed classes' do
     class_listing = ClassListing.new
     
     class_listing.enable
     simple_class.call_me
     class_listing.disable
     
     expect(class_listing.accessed_classes).to include 'Simple'
    end
  end

  context 'for a class called inside another class' do
    let(:nested_class_call) { 
      class Simple
        def call_me; end
      end

      class Nested
        def initialize
          @simple = Simple.new
        end

        def call_nested
          @simple.call_me
        end
      end

      Nested.new
    }

    it 'list all accessed classes' do
     class_listing = ClassListing.new
     
     class_listing.enable
     nested_class_call.call_nested
     class_listing.disable
     
     expect(class_listing.accessed_classes).to include('Simple', 'Nested')
    end
  end
end
