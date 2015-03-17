# encoding: UTF-8

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

FLOW_REGISTRY_OPTIONS[:preload_flows] = true

require 'minitest/unit'
require 'rails/test_help'


if ENV['SPEC_REPORTER']
  require "minitest/reporters"
  Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
end

require 'mocha/setup'

require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

class Minitest::Test
  def teardown_with_customisations
    teardown_without_customisations
    Timecop.return
    WorldLocation.reset_cache
  end
  alias_method_chain :teardown, :customisations
end

require 'gds_api/test_helpers/json_client_helper'

def fixture_file(filename)
  File.expand_path("../fixtures/#{filename}", __FILE__)
end

def read_fixture_file(filename)
  File.read(fixture_file(filename))
end
