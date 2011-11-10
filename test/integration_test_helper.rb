require_relative 'test_helper'
require 'capybara/rails'

class ActionDispatch::IntegrationTest
  include Capybara::DSL
end

class JavascriptIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end
  
  teardown do
    Capybara.use_default_driver
  end
end

Capybara.javascript_driver = 
  Gem.loaded_specs.keys.include?('capybara-webkit') ? :webkit : :selenium
Capybara.default_driver = :rack_test
Capybara.app = Rack::Builder.new do
  map "/" do
    run Capybara.app
  end
end
