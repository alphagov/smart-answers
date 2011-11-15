# encoding: UTF-8
require_relative '../integration_test_helper'

class MaternityAnswerJavascriptTest < JavascriptIntegrationTest
  include SmartAnswerTestHelper
  
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
  
  test "HTML5 History API is supported" do
    visit "/maternity"
    assert page.evaluate_script('browserSupportsHtml5HistoryApi()'), "History api supported"
  end
  
  def self.should_not_reload_after(description, &block)
    should "not reload after #{description}" do
      insert_header_content('<meta name="lost_on_reload" value="true" />')
      instance_eval &block
      assert page.has_css?('head meta[name=lost_on_reload]'), "Shouldn't have reloaded page"
    end
  end
  
  context "HTML5 history api is supported" do
    setup do
      visit "/maternity"
      click_on "Get started"
      @due_date = Date.today + 30.weeks
    end
    
    should_not_reload_after "giving due date" do
      respond_with @due_date
    end
    
    should "use url for browser history" do
      respond_with @due_date
      wait_until { has_question? "...employed...?" }
      assert_equal "/maternity/y/#{@due_date.strftime('%Y-%m-%d')}", current_path
    end
  end
  
  context "HTML5 history api is not supported" do
    setup do
      visit "/maternity"
      click_on "Get started"
      disable_history_api_support
      @due_date = Date.today + 30.weeks
    end
    
    should_not_reload_after "giving due date" do
      respond_with @due_date
    end
    
    should "use hash tags for browser history" do
      respond_with @due_date
      wait_until { has_question? "...employed...?" }
      assert_equal "#/maternity/y/#{@due_date.strftime('%Y-%m-%d')}", evaluate_script('window.location.hash')
      assert_equal "/maternity/y", current_path
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
  end
end
