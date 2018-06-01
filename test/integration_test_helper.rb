require_relative 'test_helper'
require 'capybara/rails'

Capybara.server = :webrick
Capybara.default_driver = :rack_test

require 'capybara/poltergeist'

# This additional configuration is a protective measure while
# we have invalid ssl certs in the test environment, it
# will ignore ssl errors when requesting scripts from
# assets-origin.*
#
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--ssl-protocol=TLSv1', '--ignore-ssl-errors=yes'])
end

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
    assert_same_url(current_url, path_with_query, options.merge(wait_until: true))
  end

  def assert_same_url(expected_url, actual_url, options = {})
    expected = URI.parse(expected_url)
    wait_until { expected.path == URI.parse(current_url).path } if options[:wait_until]
    actual = URI.parse(actual_url)
    assert_equal expected.path, actual.path
    unless options[:ignore_query]
      assert_equal Rack::Utils.parse_query(expected.query), Rack::Utils.parse_query(actual.query)
    end
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
