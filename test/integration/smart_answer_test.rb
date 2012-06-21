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
    visit "/question-sampler"

    assert page.has_xpath?("//meta[@name = 'description'][@content = 'Question sampler meta description']")

    within 'h1' do
      assert page.has_content?("A smart answer that covers all question types.")
    end
    within 'h2' do
      assert page.has_content?("ALL the question types...")
    end
    within '.intro' do
      assert page.has_content?("Flag Hippo")
      assert page.has_no_content?("--------") # markdown should be rendered, not output

      assert page.has_link?("Get started", :href => "/question-sampler/y")
    end
  end
end
