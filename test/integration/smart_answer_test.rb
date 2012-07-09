# encoding: UTF-8
require_relative '../integration_test_helper'

class SmartAnswerTest < ActionDispatch::IntegrationTest
  setup do
    fixture_flows_path = Rails.root.join(*%w{test fixtures flows})
    FLOW_REGISTRY_OPTIONS[:load_path] = fixture_flows_path
  end

  teardown do
    FLOW_REGISTRY_OPTIONS.delete(:load_path)
  end

  should "inspecting the start page" do
    visit "/bridge-of-death"

    assert page.has_xpath?("//meta[@name = 'description'][@content = 'The Gorge of Eternal Peril!!!']")

    within 'h1' do
      assert_page_has_content("Quick answer")
      assert_page_has_content("The Bridge of Death")
    end
    within 'h2' do
      assert_page_has_content("Avoid the Gorge of Eternal Peril!!!")
    end
    within '.intro' do
      within('h2') { assert_page_has_content("STOP!") }
      assert_page_has_content("He who would cross the Bridge of Death Must answer me These questions three Ere the other side he see.")

      assert page.has_no_content?("-----") # markdown should be rendered, not output

      assert page.has_link?("Get started", :href => "/bridge-of-death/y")
    end
  end
end
