# encoding: UTF-8

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

if Gem.loaded_specs.keys.include?('capybara-webkit')
  require 'capybara-webkit'
  Capybara.javascript_driver = :webkit
else
  Capybara.javascript_driver = :selenium
end
Capybara.default_driver = :rack_test
Capybara.app = Rack::Builder.new do
  map "/" do
    run Capybara.app
  end
end

module SmartAnswerTestHelper
  def expect_question(question_substring)
    begin
      actual_question = page.find('.current-question h2')
      assert_match question_regexp(question_substring), actual_question.text
    rescue Capybara::ElementNotFound
      raise "Expected question '#{question_substring}', but no question found"
    end
  end

  def has_question?(question_substring)
    actual_question = page.find('.current-question h2')
    !! question_regexp(question_substring).match(actual_question.text)
  end
  
  def question_regexp(question_substring)
    quoted = Regexp.quote(question_substring)
    quoted_with_ellipsis_as_wildcard = quoted.gsub(Regexp.quote('...'), ".*")
    Regexp.new(quoted_with_ellipsis_as_wildcard)
  end

  def respond_with(value)
    if page.has_css?("select[name='response[period]']")
      fill_in "response[amount]", with: value[:amount]
      select value[:period], from: "response[period]"
    elsif page.has_css?("input[name=response][type=radio]")
      choose value
    elsif page.has_css?("select[name='response[day]']")
      date = Date.parse(value.to_s)
      select date.day.to_s, from: "response[day]"
      select date.strftime('%B'), from: "response[month]"
      select date.year.to_s, from: "response[year]"
    elsif page.has_css?("input[name=response][type=text]")
      fill_in "response", with: value
    end
    click_on "Next step →"
  end
  
  def format(date)
    Date.parse(date.to_s).strftime('%e %B %Y')
  end
end
