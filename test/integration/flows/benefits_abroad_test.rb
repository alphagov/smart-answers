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
      
        setup do
          add_response :certain_countries
        end
      
        should "be question 4 for certain countries" do
          assert_current_node :question_4
        end
        
        context "eea or switzerland for question 4" do
          should "be answer 3 for eea or switzerland" do
            add_response :eea_or_switzerland
            assert_current_node :answer_3
          end  
        end

        context "gibraltar for question 4" do
          should "be answer 4 for gibraltar" do
            add_response :gibraltar
            assert_current_node :answer_4
          end
        end

        context "other listed for question 4" do
          should "be answer 5 for other listed" do
            add_response :other_listed
            assert_current_node :answer_5
          end
        end

        context "none of the above for question 4" do
          should "be answer 6 for none of the above" do
            add_response :none_of_the_above
            assert_current_node :answer_6
          end
        end
      
      end

      context "specific benefits for question 3" do
        should "be question 5 for specific benefits" do
          add_response :specific_benefits
          assert_current_node :question_5
        end
      end
    end
  end
end
