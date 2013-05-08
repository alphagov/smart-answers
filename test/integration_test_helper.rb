# encoding: UTF-8
require_relative 'test_helper'
require 'capybara/rails'
require 'slimmer/test'

Capybara.default_driver = :rack_test

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  teardown do
    Capybara.use_default_driver
  end

  def assert_page_has_content(text)
    assert page.has_content?(text), %(expected there to be content #{text} in #{page.text.inspect})
  end

  def assert_current_url(path_with_query, options = {})
    expected = URI.parse(path_with_query)
    wait_until { expected.path == URI.parse(current_url).path }
    current = URI.parse(current_url)
    assert_equal expected.path, current.path
    unless options[:ignore_query]
      assert_equal Rack::Utils.parse_query(expected.query), Rack::Utils.parse_query(current.query)
    end
  end

  def wait_until
    if Capybara.current_driver == Capybara.javascript_driver
      begin
        Timeout.timeout(Capybara.default_wait_time) do
          sleep(0.1) until yield
        end
      rescue TimeoutError
      end
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

I18n.load_path += Dir[Rails.root.join(*%w{test fixtures flows locales * *.{rb,yml}})]
