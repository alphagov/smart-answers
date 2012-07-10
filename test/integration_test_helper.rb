# encoding: UTF-8
require 'slimmer/test'
require_relative 'test_helper'
require 'capybara/rails'

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

class JavascriptIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end
end

if Gem.loaded_specs.keys.include?('poltergeist')
  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist
else
  Capybara.javascript_driver = :selenium
end
Capybara.default_driver = :rack_test
