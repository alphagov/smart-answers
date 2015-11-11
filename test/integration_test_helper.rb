require_relative 'test_helper'
require 'capybara/rails'
require 'slimmer/test'

Capybara.default_driver = :rack_test

require 'capybara/poltergeist'

require 'gds_api/test_helpers/content_api'

# This additional configuration is a protective measure while
# we have invalid ssl certs in the preview environment, it
# will ignore ssl errors when requesting scripts from
# assets-origin.preview.*
#
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { phantomjs_options: ['--ssl-protocol=TLSv1', '--ignore-ssl-errors=yes'] })
end

Capybara.javascript_driver = :poltergeist

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include GdsApi::TestHelpers::ContentApi

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

  # Adapted from http://www.elabs.se/blog/53-why-wait_until-was-removed-from-capybara
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

module Slimmer
  class Skin
    # Monkeypatch slimmer's mocked template so that we can test the behaviour of
    # showing/hiding report a problem in smart answers.
    alias :unpatched_load_template :load_template
    def load_template name
      # only override the report a problem that we need to test with specific
      # markup
      if name == "report_a_problem.raw"
        logger.debug "Monkeypatching Slimmer: TEST MODE - Loading fixture template from #{__FILE__}"
        File.read(File.join(File.dirname(__FILE__), 'fixtures', "report-a-problem.html.erb"))
      else
        unpatched_load_template name
      end
    end
  end
end
