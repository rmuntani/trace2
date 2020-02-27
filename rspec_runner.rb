# frozen_string_literal: true

require 'rspec/core'
require 'rspec'
require_relative 'lib/trace2/class_lister'
require_relative 'lib/trace2/class_use'

class_lister = ClassLister.new
class_lister.enable
RSpec::Core::Runner.run(['spec/trace2/class_lister_spec.rb:7'], $stderr, $stdout)
class_lister.disable
classes_uses = FilterUse
               .allow(class_lister.classes_uses)
               .where(caller_class: { class_name: [/RSpec::ExampleGroups::ClassLister::AccessedClasses::ForASimpleClass/] })
               .where(caller_class: { path: [/\/spec/] })
               .classes_uses
require 'pry'
binding.pry
