# frozen_string_literal: true

begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require "trace2/#{Regexp.last_match(1)}/trace2"
rescue LoadError
  require 'trace2/trace2'
end

require 'trace2/class_lister'
require 'trace2/class_use'
require 'trace2/class_use_factory'
require 'trace2/event_processor'
require 'trace2/executable_runner'
require 'trace2/filter_parser'
require 'trace2/option_parser'
require 'trace2/options'
require 'trace2/query_use'
require 'trace2/runner'
require 'trace2/version'
require 'trace2/graph_generator'
require 'trace2/reporting_tools_factory'
require 'trace2/dot_wrapper'
