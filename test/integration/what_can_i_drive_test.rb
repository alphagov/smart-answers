# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'smart_answer_test_helper'

class WhatCanIDriveTest < ActionDispatch::IntegrationTest
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

  context "Moped (Category P)" do
    setup do
      respond_with "Moped (category P)"
    end

    should "ask if you have a car licence" do
      expect_question "Do you have a full car driving licence?"
    end

    context "with a car licence" do
      setup do
        respond_with "Yes"
      end

      should "be allowed if issued before Feb 2001" do
        expect_question "Was your licence issued before 1 February 2001?"
        respond_with "Yes"

        assert_results_contain "Yes, your driving licence should already let you drive a moped without taking compulsory basic training (CBT)."
      end

      should "require CBT if issues after Feb 2001" do
        expect_question "Was your licence issued before 1 February 2001?"
        respond_with "No"

        assert_results_contain "Yes, but you need to take a CBT (category P)"
      end
    end # With a car licence

    context "without a car licence" do
      setup do
        respond_with "No"
      end

      should "not be allowed if under 16" do
        expect_question "How old are you?"
        respond_with "Under 16 years"

        assert_results_contain "No, you can't start riding a moped until you're 16."
      end

      should "be allowed if 16 or over" do
        expect_question "How old are you?"
        respond_with "16 years and over"

        assert_results_contain "Yes (category P)"
      end
    end # without a car licence
  end # Moped

  context "Motorbike (category A)" do
    setup do
      respond_with "Motorbike (category A)"
    end

    should "not be allowrd when under 17" do
      expect_question "How old are you?"
      respond_with "Under 17 years"

      assert_results_contain "No, you are under 17"
    end

    should "be allowed when 22 or over" do
      expect_question "How old are you?"
      respond_with "22 years and over"

      assert_results_contain "Yes. You can go through direct access to ride any type of motorbike (category A, A1)"
    end

    context "when 17-20" do
      setup do
        respond_with "17 to 20 years"
      end

      should "allow limited without a full licence" do
        expect_question "Do you already have a full motorcycle licence?"
        respond_with "No"

        assert_results_contain "Yes, but you can only ride bikes under X size for two years after passing your test (category A, A1)"
      end

      context "with a full licence" do
        setup do
          respond_with "Yes"
        end

        should "Allow any bike if had licence for more than 2 years" do
          expect_question "Have you had your motorcycle licence for more than 2 years?"
          respond_with "Yes"

          assert_results_contain "Yes. And you can now ride ANY type of motorbike as you've had your licence for over 2 years (category A, A1)"
        end

        should "Allow limited bikes if had licence for less than 2 years" do
          expect_question "Have you had your motorcycle licence for more than 2 years?"
          respond_with "No"

          assert_results_contain "Yes, but you can only ride bikes under X size (category A, A1)"
        end
      end # full licence
    end #17-20

    context "when 21" do
      setup do
        respond_with "21 years"
      end

      should "allow limited without a full licence" do
        expect_question "Do you already have a motorcycle licence?"
        respond_with "No"

        assert_results_contain "Yes. You can go through direct access to ride any type of motorbike (category A, A1)"
      end

      context "with a full licence" do
        setup do
          respond_with "Yes"
        end

        should "Allow any bike if had licence for more than 2 years" do
          expect_question "Have you had your motorcycle licence for more than 2 years?"
          respond_with "Yes"

          assert_results_contain "Yes. And you can now ride ANY type of motorbike as you've had your licence for over 2 years (category A, A1)"
        end

        should "Allow limited bikes if had licence for less than 2 years" do
          expect_question "Have you had your motorcycle licence for more than 2 years?"
          respond_with "No"

          assert_results_contain "Yes. And you can now undertake an accelerated access thing to let you ride any type of motorbike (category A, A1)"
        end
      end # full licence
    end # 21
  end # Motorbike

  context "Medium vehicle (category C1)" do
    setup do
      respond_with "Medium-sized vehicles (category C1)"
    end

    should "not be allowed without a full car licence" do
      expect_question "Do you have a full car driving licence?"
      respond_with "No"

      assert_results_contain "You need a car licence (category B) before you can drive one of these"
    end

    context "with a full car licence" do
      setup do
        respond_with "Yes"
      end

      should "ask for your age" do
        expect_question "How old are you?"
      end

      should "allow C1 and E if 21 or over" do
        respond_with "21 years and over"

        assert_results_contain "Yes, you can drive a van with a trailer. (category C1+E)"
      end

      should "allow C1 if 18-20" do
        respond_with "18 to 20 years"

        assert_results_contain "Yes, you can drive a van (category C1)"
      end

      should "not be allowed if 17 unless in army" do
        respond_with "17 years"

        assert_results_contain "Sorry, you can't drive a van if you are 17 unless you are in the army"
      end

      should "not be allowed if under 17" do
        respond_with "Under 17 years"

        assert_results_contain "You can't drive a van if you're under 17."
      end
    end
  end # Medium vehicle

  context "Large vehicle (category C)" do
    setup do
      respond_with "Large vehicles and lorries (category C)"
    end

    should "not be allowed without a full car licence" do
      expect_question "Do you have a full car driving licence?"
      respond_with "No"

      assert_results_contain "You need a car licence (category B) before you can drive one of these"
    end

    context "with a full car licence" do
      setup do
        respond_with "Yes"
      end

      should "ask for your age" do
        expect_question "How old are you?"
      end

      should "allow C1 and E if 21 or over" do
        respond_with "21 years and over"

        assert_results_contain "Yes, you can drive a lorry (category C). Also a trailer if you take an additional test"
      end

      should "allow C1 if 18-20" do
        respond_with "18 to 20 years"

        assert_results_contain "Yes, you can drive a lorry (category C) under special circumstances which Graham will describe"
      end

      should "not be allowed if 17 unless in army" do
        respond_with "17 years"

        assert_results_contain "Sorry, you can't drive a lorry if you are 17 unless you are in the army"
      end

      should "not be allowed if under 17" do
        respond_with "Under 17 years"

        assert_results_contain "Sorry, you can't drive a lorry if you are under 17"
      end
    end # with a car licence
  end # Large vehicle

  context "Bus (category D)" do
    setup do
      respond_with "Bus (category D)"
    end

    should "not be allowed without a full car licence" do
      expect_question "Do you have a full car driving licence?"
      respond_with "No"

      assert_results_contain "You need a car licence (category B) before you can drive one of these"
    end

    context "with a full car licence" do
      setup do
        respond_with "Yes"
      end

      should "ask for your age" do
        expect_question "How old are you?"
      end

      should "be allowed if 21 or over" do
        respond_with "21 years and over"

        assert_results_contain "Yes (category D)"
      end

      should "allow with special circumstances if 20" do
        respond_with "20 years"

        assert_results_contain "Yes, with special circumstances (category D) [20 years]"
      end

      should "allow with special circumstances if 18-19" do
        respond_with "18 to 19 years"

        assert_results_contain "Yes, with special circumstances (category D) [18+19 years]"
      end

      should "not be allowed if 17 unless in army" do
        respond_with "17 years"

        assert_results_contain "Sorry, you can't drive a bus if you are 17 unless you are in the army"
      end

      should "not be allowed if under 17" do
        respond_with "Under 17 years"

        assert_results_contain "Sorry, you can't drive a bus if you are under 17"
      end
    end # with a car licence
  end # Bus

  context "Minibus (category D1)" do
    setup do
      respond_with "Minibus (category D1)"
    end

    should "not be allowed without a full car licence" do
      expect_question "Do you have a full car driving licence?"
      respond_with "No"

      assert_results_contain "You need a car licence (category B) before you can drive one of these"
    end

    context "with a full car licence" do
      setup do
        respond_with "Yes"
      end

      should "ask for your age" do
        expect_question "How old are you?"
      end

      should "be allowed if 21 or over" do
        respond_with "21 years and over"

        assert_results_contain "Yes (category D1)"
      end

      should "allow with special circumstances if 20" do
        respond_with "20 years"

        assert_results_contain "Yes, with special circumstances (category D1) [20 years]"
      end

      should "allow with special circumstances if 18-19" do
        respond_with "18 to 19 years"

        assert_results_contain "Yes, with special circumstances (category D1) [18+19 years]"
      end

      should "not be allowed if 17 unless in army" do
        respond_with "17 years"

        assert_results_contain "Sorry, you can't drive a minibus if you are 17 unless you are in the army"
      end

      should "not be allowed if under 17" do
        respond_with "Under 17 years"

        assert_results_contain "Sorry, you can't drive a minibus if you are under 17"
      end
    end # with a car licence
  end # Minibus

  context "Agricultural tractor (category F)" do
    setup do
      respond_with "Agricultural tractor (category F)"
    end

    should "be allowed with a full car licence" do
      expect_question "Do you have a full car driving licence?"
      respond_with "Yes"

      assert_results_contain "Yes but no but... (category F)"
    end

    context "without a full car licence" do
      setup do
        respond_with "No"
      end

      should "ask for your age" do
        expect_question "How old are you?"
      end

      should "be allowed if 17 or over" do
        respond_with "17 years and over"

        assert_results_contain "You can apply for a provisional category F entitlement to drive any type of tractor."
      end

      should "allow small tractors if 16" do
        respond_with "16 years"

        assert_results_contain "You can drive some smaller tractors."
      end

      should "not be allowed if under 16" do
        respond_with "Under 16 years"

        assert_results_contain "No, you can't drive a tractor."
      end
    end # with a car licence
  end # Tractor

  context "Other (categories G, H and K)" do
    setup do
      respond_with "Other specialist vehicles (categories G, H and K)"
    end

    should "ask for your age" do
      expect_question "How old are you?"
    end

    should "allow G, H and K if 21 or over" do
      respond_with "21 years and over"

      assert_results_contain "Yes, you can drive category G, H and K vehicles"
    end

    should "allow G, H and K (with restricitons in H and K) if 17-20 years old" do
      respond_with "17 to 20 years"

      assert_results_contain "Yes, you can drive category K vehicles (and G/H under special circumstances)"
    end

    should "allow K if 16" do
      respond_with "16 years"

      assert_results_contain "Yes, you can drive category K vehicles"
    end

    should "not be allowed if under 16" do
      respond_with "Under 16 years"

      assert_results_contain "No, you are under 16"
    end
  end # Other

  context "Quad bike or Trike (category B1)" do
    setup do
      respond_with "Quad bike or trike (category B1)"
    end

    should "be allowed if you have a licence" do
      expect_question "Do you have a full car driving licence?"
      respond_with "Yes"

      assert_results_contain "Yes you can (category B1)"
    end

    context "without a licence" do
      setup do
        respond_with "No"
      end

      should "not be able to drive if under 16" do
        expect_question "How old are you?"
        respond_with "Under 16 years"

        assert_results_contain "No, you are under 16"
      end

      should "be able to drive if 17 or over" do
        expect_question "How old are you?"
        respond_with "17 years and over"

        assert_results_contain "Yes, you are over 17 (category B1)"
      end

      context "if aged 16" do
        setup do
          respond_with "16 years"
        end

        should "be able to drive if getting DLA" do
          expect_question "Are you getting the higher rate mobility component of Disability Living Allowance (DLA)?"
          respond_with "Yes"

          assert_results_contain "Yes as you are getting DLA (category B1)"
        end

        should "not be able to drive otherwise" do
          expect_question "Are you getting the higher rate mobility component of Disability Living Allowance (DLA)?"
          respond_with "No"

          assert_results_contain "No, you are under 16"
        end
      end # aged 16
    end # without a licence
  end # Quad bike or Trike
end
