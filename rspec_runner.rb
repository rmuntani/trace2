# frozen_string_literal: true

require 'rspec/core'
require 'rspec'
require_relative 'lib/trace2/class_lister'
require_relative 'lib/trace2/class_use'

class_lister = ClassLister.new
class_lister.enable
RSpec::Core::Runner.run(['spec/'], $stderr, $stdout)
class_lister.disable
puts class_lister.accessed_classes.tally
