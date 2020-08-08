# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

PROJECT_ROOT = File.expand_path('..', __dir__)

# lib/trace2.rb does all the requires that are necessary
require File.join(PROJECT_ROOT, 'lib', 'trace2.rb')

Dir.glob(File.join(PROJECT_ROOT, 'spec', 'fixtures', '*.rb')).sort.each do |file|
  require file
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = 'spec/examples.txt'
end
