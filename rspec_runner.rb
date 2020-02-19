# frozen_string_literal: true

require 'rspec/core'
require 'rspec'
require_relative 'lib/trace2/class_listing'
require_relative 'lib/trace2/class_use'

class_listing = ClassListing.new
class_listing.enable
RSpec::Core::Runner.run(['spec/'], $stderr, $stdout)
class_listing.disable
puts class_listing.accessed_classes.tally
