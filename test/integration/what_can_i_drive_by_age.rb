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
    choose_age "Under 16"

    # FIXME: how can I get around this HTML encoding?
    assert_match /You can&\#8217;t drive anything/, page.body
  end

  test "16 year olds asked about DLA" do
    choose_age "16"

    assert_match /I get DLA/, page.body
  end

  test "16 year olds with DLA" do
    choose_age "16"

    choose "I get DLA"
    click_button "Next step"

    assert_contains_licence_codes %w(B K F P B1)
  end

  test "16 year olds without DLA" do
    choose_age "16"

    choose "I do not get DLA"
    click_button "Next step"

    assert_contains_licence_codes %w(K P F)
  end

private

  def choose_age(age)
    choose age
    click_button "Next step"
  end

  def assert_contains_licence_codes(codes)
    for code in codes do
      assert_match "[#{code}]", page.body
    end
  end
end
