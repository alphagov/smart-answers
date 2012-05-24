# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'maternity_answer_logic'
require_relative 'smart_answer_test_helper'

class WhatCanIDriveByAgeTest < ActionDispatch::IntegrationTest
  def setup
    visit "/what-can-i-drive-by-age"
    click_on "Get started"
  end

  test "< 16 year olds can't drive" do
    choose "Under 16"
    click_button "Next step"

    # FIXME: how can I get around this HTML encoding?
    assert_match /You can&\#8217;t drive anything/, page.body
  end
end
