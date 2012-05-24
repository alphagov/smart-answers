# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'maternity_answer_logic'
require_relative 'smart_answer_test_helper'

class WhatCanIDriveByAgeTest < ActionDispatch::IntegrationTest
  include SmartAnswerTestHelper

  def setup
    visit "/what-can-i-drive-by-age"
    click_on "Get started"
  end

  test "< 16 year olds can't drive" do
    choose_age "Under 16"

    assert page.has_content? "You can’t drive anything"
  end

  test "16 year olds asked about DLA" do
    choose_age "16"

    assert_match /I get DLA/, page.body
  end

  test "16 year olds with DLA" do
    choose_age "16"

    choose_and_next "I get DLA"

    assert_contains_licence_codes %w(B K F P B1)
  end

  test "16 year olds without DLA" do
    choose_age "16"

    choose_and_next "I do not get DLA"

    assert_contains_licence_codes %w(K P F)
  end

  test "17 years old" do
    choose_age "17"

    expect_question "Are you in the armed forces?"
  end

  test "17 years old not in military" do
    choose_age "17"

    choose_and_next "I am not a member of the Armed Forces"

    assert_contains_licence_codes ["B", "K", "F", "P", "B1", "A, A1"]
  end

private

  def choose_and_next(choice)
    choose choice
    click_next_step
  end

  def choose_age(age)
    choose_and_next age
  end

  def assert_contains_licence_codes(codes)
    for code in codes do
      assert_match "[#{code}]", page.body
    end
  end
end
