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

    assert page.has_content? "Are you getting Disability Living Allowance (DLA)?"
  end

  test "16 year olds with DLA" do
    choose_age "16"

    choose_and_next "I get DLA"

    assert_contains_licence_codes ["B", "K", "F", "P", "B1"]
  end

  test "16 year olds without DLA" do
    choose_age "16"

    choose_and_next "I do not get DLA"

    assert_contains_licence_codes ["K", "P", "F"]
  end

  test "17 years old" do
    choose_age "17"

    expect_question "Are you in the armed forces?"
  end

  test "17 years old not in military" do
    choose_age "17"

    not_in_armed_forces

    assert_contains_licence_codes ["B", "K", "F", "P", "B1"]
    assert_contains_restricted_licence_codes ["A, A1", "G, H"]
  end

  test "17 years old in military" do
    choose_age "17"

    in_armed_forces

    assert_contains_licence_codes ["B", "K", "F", "P", "B1", "C1", "C", "D1", "D"]
    assert_contains_restricted_licence_codes ["A, A1", "G, H"]
  end

  test "18 years old not in military" do
    choose_age "18"

    not_in_armed_forces

    assert_contains_licence_codes ["B", "K", "F", "P", "B1"]
    assert_contains_restricted_licence_codes ["A, A1", "C", "C1", "G, H"]
  end

  test "18 years old in military" do
    choose_age "18"

    in_armed_forces

    assert_contains_licence_codes ["B", "K", "F", "P", "B1", "C1", "C", "D1", "D"]
    assert_contains_restricted_licence_codes ["A, A1", "G, H"]
  end

  test "19 or 20 years old not in military" do
    choose_age "19 or 20"

    not_in_armed_forces

    assert_contains_licence_codes ["B", "K", "F", "P", "B1"]
    assert_contains_restricted_licence_codes ["C1", "C", "D1", "D", "A, A1", "G, H"]
  end

  test "19 or 20 years old in military" do
    choose_age "19 or 20"

    in_armed_forces

    assert_contains_licence_codes ["B", "K", "F", "P", "B1", "C1", "C", "D1", "D"]
    assert_contains_restricted_licence_codes ["A, A1", "G, H"]
  end

  test "21 years old" do
    choose_age "21"

    assert_contains_licence_codes ["B", "K", "F", "P", "B1", "C1", "C", "D1", "D", "G, H"]
    assert_contains_restricted_licence_codes ["A, A1"]
  end

  test "22 years old or older" do
    choose_age "22 or older"

    assert_contains_licence_codes ["B", "K", "F", "P", "B1", "A, A1", "C1", "C", "D1", "D", "G, H"]
  end

private

  def choose_and_next(choice)
    choose choice
    click_next_step
  end

  def in_armed_forces
    choose_and_next "I am a member of the Armed Forces"
  end

  def not_in_armed_forces
    choose_and_next "I am not a member of the Armed Forces"
  end

  def choose_age(age)
    choose_and_next age
  end

  def assert_contains_licence_codes(codes)
    for code in codes do
      assert_match %r|\[#{code}\](?!\*)|, page.body
    end
  end

  def assert_contains_restricted_licence_codes(codes)
    for code in codes do
      assert_match %r|\[#{code}\]\*|, page.body
    end
  end
end
