# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'maternity_answer_logic'
require_relative 'smart_answer_test_helper'

class MaternityAnswerJavascriptTest < JavascriptIntegrationTest
  include SmartAnswerTestHelper
  include MaternityAnswerHelpers
  extend MaternityAnswerLogic

  should_implement_materntiy_answer_logic

  def escape_for_js(value)
    value.gsub("'", "\\'").gsub('\\', '\\\\')
  end

  def insert_header_content(content)
    escaped = escape_for_js(content)
    page.execute_script(%Q{$('head').append($('#{content}'))})
  end

  def disable_history_api_support
    page.execute_script(%q{browserSupportsHtml5HistoryApi = function() {return false;}})
  end

  def go(direction)
    page.execute_script("window.history.#{direction}()")
  end

  def self.should_not_reload_after(description, &block)
    should "not reload after #{description}" do
      insert_header_content('<meta name="lost_on_reload" value="true" />')
      instance_eval &block
      assert page.has_css?('head meta[name=lost_on_reload]'), "Shouldn't have reloaded page"
    end
  end

  context "HTML5 Pushstate/Ajax behaviour" do
    setup do
      visit "/maternity"
      click_on "Get started"
      @due_date = Date.today + 30.weeks
    end

    should_not_reload_after "giving due date" do
      respond_with @due_date
    end

    should_not_reload_after "giving due date and employment status" do
      respond_with @due_date
      wait_until { has_question? "...employed...?" }
      respond_with "Yes"
    end

    should_not_reload_after "going back in history" do
      respond_with @due_date
      wait_until { has_question? "...employed...?" }
      respond_with "Yes"
      wait_until { has_question? "Did you start your current job...?" }
      go :back
      wait_until(30) { has_question? "...employed...?" }
    end

    should_not_reload_after "going back then forward in history" do
      respond_with @due_date
      respond_with "Yes"
      expect_question "Did you start your current job...?"
      go :back
      wait_until(30) { has_question? "...employed...?" }
      go :forward
      wait_until(30) { has_question? "Did you start your current job...?" }
    end

    context "visiting another page then going back" do
      should "reload page correctly" do
        respond_with @due_date
        wait_until { has_question? "...employed...?" }
        visit "/materninty"
        wait_until { has_css?("a", /Get started/) }
        go :back
        wait_until { has_question? "...employed...?" }
      end
    end
  end

  context "Visiting a smart answer" do
    setup do
      visit "/maternity"
    end

    should "demonstrate the history API is available" do
      assert page.evaluate_script('browserSupportsHtml5HistoryApi()'), "History api supported"
    end
  end
end
