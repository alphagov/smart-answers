# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BenefitsAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'benefits-abroad'
  end

  should "ask have you told JobCentre plus" do
    assert_current_node :question_1
  end

  should "be answer_1 for no" do
    add_response :no
    assert_current_node :answer_1
  end

  context "yes to question 1" do
    setup do
      add_response :yes
    end

    should "be question_2 for yes" do
      assert_current_node :question_2
    end
  
    should "be answer 2 for no" do
      add_response :no
      assert_current_node :answer_2
    end

    context "yes to question 2" do
      setup do
        add_response :yes
      end

      should "be question 3 for yes" do
        assert_current_node :question_3
      end

      context "certain countries for question 3" do
        should "be question 4 for certain countries" do
          add_response :certain_countries
          assert_current_node :question_4
        end
      end

      context "specific benefits for question 3" do
        setup do
          add_response :specific_benefits
        end

        should "be question 5 for specific benefits" do
          assert_current_node :question_5
        end

        should "be answer 7 for pension" do
          add_response :pension
          assert_current_node :answer_7
        end

        context "jsa for question 5" do
          setup do
            add_response :jsa
          end

          should "be question 6 for jsa" do
            assert_current_node :question_6
          end
        end

        context "wfp for question 5" do
          setup do
            add_response :wfp
          end

          should "be question 7 for wfp" do
            assert_current_node :question_7
          end
        end
      end
    end
  end
end