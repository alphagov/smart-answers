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

  def assert_page_has_content(text)
    assert page.has_content?(text), %(expected there to be content #{text} in #{page.text.inspect})
  end

  def assert_current_url(path_with_query, options = {})
    expected = URI.parse(path_with_query)
    current = URI.parse(current_url)
    assert_equal expected.path, current.path
    unless options[:ignore_query]
      assert_equal Rack::Utils.parse_query(expected.query), Rack::Utils.parse_query(current.query)
    end
  end

  def self.with_javascript
    context "with javascript" do
      setup do
        Capybara.current_driver = Capybara.javascript_driver
      end

      yield
    end
  end

  def self.without_javascript
    context "without javascript" do

      yield
    end
  end

  def self.with_and_without_javascript
    without_javascript do
      yield
    end

    with_javascript do
      yield
    end
  end
end

class JavascriptIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end
end

if Gem.loaded_specs.keys.include?('capybara-webkit')
  require 'capybara-webkit'
  Capybara.javascript_driver = :webkit
else
  Capybara.javascript_driver = :selenium
end
Capybara.default_driver = :rack_test

I18n.load_path += Dir[Rails.root.join(*%w{test fixtures flows locales * *.{rb,yml}})]

require 'webmock/test_unit'
WebMock.disable_net_connect!(:allow_localhost => true)
