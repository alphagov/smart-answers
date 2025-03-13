require_relative "test_helper"
require "capybara/rails"

Capybara.server = :webrick
Capybara.default_driver = :rack_test

GovukTest.configure

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  teardown do
    Capybara.use_default_driver
  end

  def assert_page_has_content(text)
    assert page.has_content?(text), %(expected there to be content #{text} in #{page.text.inspect})
  end

  def assert_current_url(path_with_query)
    expected = URI.parse(path_with_query)
    wait_until { expected.path == URI.parse(current_url).path }
    current = URI.parse(current_url)
    assert_equal expected.path, current.path
    assert_equal Rack::Utils.parse_query(expected.query), Rack::Utils.parse_query(current.query)
  end

  def assert_same_url(expected_url, actual_url)
    expected = URI.parse(expected_url)
    actual = URI.parse(actual_url)
    assert_equal expected.path, actual.path
    assert_equal Rack::Utils.parse_query(expected.query), Rack::Utils.parse_query(actual.query)
  end

  # Adapted from http://www.elabs.se/blog/53-why-wait_until-was-removed-from-capybara
  def wait_until
    if Capybara.current_driver == Capybara.javascript_driver
      begin
        Timeout.timeout(Capybara.default_max_wait_time) do
          sleep(0.1) until yield
        end
      rescue Timeout::Error => e
        p e
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

  def self.without_javascript(&block)
    context "without javascript", &block
  end

  def self.with_and_without_javascript(&block)
    without_javascript(&block)

    with_javascript(&block)
  end
end
