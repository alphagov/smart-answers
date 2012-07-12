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
          
          context "eea, switzerland, gibraltar for question 6" do
            should "be answer 8" do
              add_response :eea_switzerland_gibraltar
              assert_current_node :answer_8
            end
          end
          
          context "jersey, etc. for question 6" do
            should "be answer 9" do
              add_response :jersey_etc
              assert_current_node :answer_9
            end            
          end
          
          context "none of the above for question 6" do
            should "be answer 9" do
              add_response :none_of_the_above
              assert_current_node :answer_10
            end           
          end
          
        end

        context "wfp for question 5" do
          setup do
            add_response :wfp
          end

          should "be question 7" do
            assert_current_node :question_7
          end
          
          context "eea switzerland gibraltar for question 7" do
            
            setup do
              add_response :eea_switzerland_gibraltar
            end
            
            should "be question 8" do
              assert_current_node :question_8
            end
            
            context "yes for question 8" do
              should "be answer 12" do
                add_response :yes
                assert_current_node :answer_12
              end
            end
            
            context "no for question 8" do
              should "should be answer 11" do
                add_response :no
                assert_current_node :answer_11
              end
            end
          end
          
          context "other for question 7" do
            should "be answer 11" do
              add_response :other
              assert_current_node :answer_11
            end
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

            should "be question 10" do
              assert_current_node :question_10
            end
          end

          context "not EEA for question 9" do
            setup do
              add_response :not_eea
            end

            should "be question 12" do
              assert_current_node :question_12
            end
          end
        end

        context "child benefits for question 5" do
          setup do
            add_response :child_benefits
          end

          should "be question 13" do
            assert_current_node :question_13
          end
        end

        context "ssp for question 5" do
          setup do
            add_response :ssp
          end

          should "be question 15" do
            assert_current_node :question_15
          end
        end

        context "tax credits for question 5" do
          setup do
            add_response :tax_credits
          end

          should "be question 18" do
            assert_current_node :question_18
          end
        end

        context "esa for question 5" do
          setup do
            add_response :esa
          end

          should "be question 25" do
            assert_current_node :question_25
          end
        end

        context "industrial injuries for question 5" do
          setup do
            add_response :industrial_injuries
          end

          should "be question 27" do
            assert_current_node :question_27
          end
        end

        context "disability for question 5" do
          setup do
            add_response :disability
          end

          should "be question 29" do
            assert_current_node :question_29
          end
        end

        context "bereavement for question 5" do
          setup do
            add_response :bereavement
          end

          should "be question 35" do
            assert_current_node :question_35
          end
        end

      end
    end
  end
end
