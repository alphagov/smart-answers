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

          should "be question 6" do
            assert_current_node :question_6
          end
        end

        context "wfp for question 5" do
          setup do
            add_response :wfp
          end

          should "be question 7" do
            assert_current_node :question_7
          end
        end

        context "maternity for question 5" do
          setup do
            add_response :maternity
          end

          should "be question 9" do
            assert_current_node :question_9
          end

          context "EEA for question 9" do
            setup do
              add_response :eea
            end

            should "ask 'Are you working for a UK employer?'" do
              assert_current_node :uk_employer
            end
          end

          context "not EEA for question 9" do
            setup do
              add_response :not_eea
            end

            should "ask 'employer paying NI contributions for you?'" do
              assert_current_node :employer_paying_ni
            end
          end
        end

        context "child benefits for question 5" do
          setup do
            add_response :child_benefits
          end

          should "ask 'Are you moving to?'" do
            assert_current_node :moving_to
          end
        end

        context "ssp for question 5" do
          setup do
            add_response :ssp
          end

          should "ask 'Are you moving to a country?'" do
            assert_current_node :moving_country
          end
        end

        context "tax credits for question 5" do
          setup do
            add_response :tax_credits
          end

          should "ask 'Are you claiming tax credits or eligible?'" do
            assert_current_node :claiming_tax_credits_or_eligible
          end
        end

        context "esa for question 5" do
          setup do
            add_response :esa
          end

          should "ask 'Are you claiming ESA and going abroad for?'" do
            assert_current_node :claiming_esa_abroad_for
          end
        end

        context "industrial injuries for question 5" do
          setup do
            add_response :industrial_injuries
          end

          should "ask 'claiming Disablement Benefit before moving overseas?'" do
            assert_current_node :claiming_iidb
          end
        end

        context "disability for question 5" do
          setup do
            add_response :disability
          end

          should "ask 'Are you currently getting any of the following?'" do
            assert_current_node :getting_any_allowances
          end
        end

        context "bereavement for question 5" do
          setup do
            add_response :bereavement
          end

          should "ask 'Are you eligible for the following?'" do
            assert_current_node :eligible_for_the_following
          end
        end

      end
    end
  end
end
