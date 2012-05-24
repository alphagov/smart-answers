# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'smart_answer_test_helper'

class WhatCanIDriveByAgeTest < ActionDispatch::IntegrationTest
  include SmartAnswerTestHelper

  setup do
    visit "/what-can-i-drive"
    click_on "Get started"
  end

  should "ask what kind of vehicle you want to drive" do
    expect_question "What kind of vehicle do you want to drive?"
  end

  context "Car (category B)" do
    setup do
      respond_with "Car or light vehicle (category B)"
    end

    should "be allowed if you have a licence" do
      expect_question "Do you have a driving licence?"
      respond_with "Yes"

      assert_results_contain "You may already be able to drive a car."
    end

    context "without a licence" do
      setup do
        respond_with "No"
      end

      should "not be able to drive if under 16" do
        expect_question "How old are you?"
        respond_with "Under 16 years"

        assert_results_contain "No, you can't drive a car or light vehicle yet."
      end

      should "be able to drive if 17 or over" do
        expect_question "How old are you?"
        respond_with "17 years and over"

        assert_results_contain "Yes, you can apply for a provisional licence and start learning to drive a car."
      end

      context "if aged 16" do
        setup do
          respond_with "16 years"
        end

        should "be able to drive if getting DLA" do
          expect_question "Are you getting the higher rate mobility component of Disability Living Allowance (DLA)?"
          respond_with "Yes"

          assert_results_contain "Yes, you can start learning to drive a car."
        end

        should "not be able to drive otherwise" do
          expect_question "Are you getting the higher rate mobility component of Disability Living Allowance (DLA)?"
          respond_with "No"

          assert_results_contain "No, you can't drive a car or light vehicle yet."
        end
      end # aged 16
    end # without a licence
  end # Car

end
