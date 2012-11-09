# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class StudentFinanceCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'student-finance-calculator'
  end

  should "ask when your course starts" do
    assert_current_node :when_does_your_course_start?
  end

  context "course starting between 2012 and 2013" do
    setup do
      add_response '2012-2013'
    end

    should "ask if you are full-time or part-time student" do
      assert_current_node :are_you_a_full_time_or_part_time_student?
    end

    context "full-time student between 2012 and 2013" do
      setup do
        add_response 'full-time'
      end

      should "ask how much your tuition fees are per year" do
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end

      should "be invalid if a fee over 9000 is entered" do
        add_response '9001'
        assert_current_node_is_error
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end

      context "with valid fees entered" do
        setup do
          add_response '8490'
        end

        should "ask where you will live while studying" do
          assert_current_node :where_will_you_live_while_studying?
        end

        context "living at home" do
          setup do
            add_response 'at-home'
          end

          should "ask whats your household income" do
            assert_current_node :whats_your_household_income?
          end

          context "household income up to 25k" do
            setup do
              add_response '24500'
            end

            should "ask if you want to check for additional grants etc" do
              assert_current_node :full_time_do_you_want_to_check_for_additional_grants_and_allowances?
            end

            should "be done if not checking for additional grants etc." do
              add_response 'no'
              assert_current_node :done
              assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan, :maintenance_grant]
              assert_state_variable :tuition_fee_amount, 8490
              assert_state_variable :maintenance_loan_amount, 2750 #4375 - (maintenance_grant_amount/2.0).floor
              assert_state_variable :maintenance_grant_amount, 3250
              assert_phrase_list :additional_benefits, []
            end

            # 'yes' branch tested below

          end # up to 25k

          should "be done if 30k and not checking additional grants" do
            add_response '30000'
            add_response 'no'

            assert_current_node :done
            assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan, :maintenance_grant]
            assert_state_variable :maintenance_grant_amount, 2341
            assert_state_variable :maintenance_loan_amount, 3205
          end

          should "be done if 35k and not checking additional grants" do
            add_response '35000'
            add_response 'no'

            assert_current_node :done
            assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan, :maintenance_grant]
            assert_state_variable :maintenance_grant_amount, 1432
            assert_state_variable :maintenance_loan_amount, 3659
          end

          should "be done if 40k and not checking additional grants" do
            add_response '40000'
            add_response 'no'

            assert_current_node :done
            assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan, :maintenance_grant]
            assert_state_variable :maintenance_grant_amount, 523
            assert_state_variable :maintenance_loan_amount, 4114
          end

          should "be done if 42.6k and not checking additional grants" do
            add_response '42600'
            add_response 'no'

            assert_current_node :done
            assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan, :maintenance_grant]
            assert_state_variable :maintenance_grant_amount, 50
            assert_state_variable :maintenance_loan_amount, 4350
          end

          should "be done if 42.6000 - 42875 and not checking additional grants" do
            add_response '42875'
            add_response 'no'

            assert_current_node :done
            assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan]
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 4375
          end


          should "be done and min loan amount if 58195 and not checking additional grants" do
            add_response '58195'
            add_response 'no'

            assert_current_node :done
            assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan]
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 2843
          end

          should "be done and min loan amount if 60k and not checking additional grants" do
            add_response '60000'
            add_response 'no'

            assert_current_node :done
            assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan]
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 2843
          end


        end # at-home

        context "living away from home, outside London" do
          setup do
            add_response 'away-outside-london'
          end

          should "set max maintenance loan of 5500" do
            assert_state_variable :max_maintenance_loan_amount, 5500
          end

          should "ask about household income" do
            assert_current_node :whats_your_household_income?
          end

          # additional maintenance grant and loan tests for living away from home, outside London
          should "display correct grant and loan for under 25k" do
            add_response 24500
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 3250
            assert_state_variable :maintenance_loan_amount, 3875
          end

          should "display correct grant and loan for 30k" do
            add_response 30000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 2341
            assert_state_variable :maintenance_loan_amount, 4330
          end

          should "display correct grant and loan for 35k" do
            add_response 35000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 1432
            assert_state_variable :maintenance_loan_amount, 4784
          end

          should "display correct grant and loan for 40k" do
            add_response 40000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 523
            assert_state_variable :maintenance_loan_amount, 5239
          end


          should "display correct grant and loan for 42601" do
            add_response 42601
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 5500
          end

          should "display correct grant and loan for 45k" do
            add_response 45000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 5288
          end

          should "display correct min loan amount for 65k" do
            add_response 65000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 3575
          end

        end # away-outside-london

        context "living away from home, in London" do
          setup do
            add_response 'away-in-london'
          end

          should "set max maintenance loan of 7675" do
            assert_state_variable :max_maintenance_loan_amount, 7675
          end

          should "ask about household income" do
            assert_current_node :whats_your_household_income?
          end

          # additional maintenance grant and loan tests for living away from home, in London
          should "display correct grant and loan for under 25k" do
            add_response 24500
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 3250
            assert_state_variable :maintenance_loan_amount, 6050
          end

          should "display correct grant and loan for 30k" do
            add_response 30000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 2341
            assert_state_variable :maintenance_loan_amount, 6505
          end

          should "display correct grant and loan for 35k" do
            add_response 35000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 1432
            assert_state_variable :maintenance_loan_amount, 6959
          end

          should "display correct grant and loan for 40k" do
            add_response 40000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 523
            assert_state_variable :maintenance_loan_amount, 7414
          end


          should "display correct grant and loan for 42601" do
            add_response 42601
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 7675
          end

          should "display correct grant and loan for 45k" do
            add_response 45000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 7463
          end

          should "display correct loan amount for 65k" do
            add_response 65000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 5463
          end

          should "display correct min loan amount for 70k" do
            add_response 70000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 4988
          end

        end # away-in-london

      end # with fees


      context "testing for :done outcome phrase_list alterations" do
        setup do
          add_response '8490'
          add_response 'away-outside-london'
          add_response '24000'
          add_response 'yes'
        end

        should "include benefits " do
          add_response 'no'
          add_response 'no'
          add_response 'yes'
          add_response 'yes'
          add_response 'teacher-training'
          assert_phrase_list :additional_benefits, [:body, :disability, :financial_hardship, :teacher_training]
          assert_phrase_list :extra_grants, []
          assert_current_node :done
        end

        should "include no benefits " do
          add_response 'no'
          add_response 'no'
          add_response 'no'
          add_response 'no'
          add_response 'none'
          assert_phrase_list :additional_benefits, []
          assert_phrase_list :extra_grants, [:additional_grants_and_allowances]
          assert_current_node :done
        end

      end

      context "checking for additional grants" do
        setup do
          add_response '8490'
          add_response 'at-home'
          add_response '23000'
          add_response 'yes'
        end

        should "ask if you have any children under 17" do
          assert_current_node :do_you_have_any_children_under_17?
        end

        should "ask if another adult depends on you financially" do
          add_response 'yes'
          assert_current_node :does_another_adult_depend_on_you_financially?
        end

        should "ask if you have a disability" do
          add_response 'no'
          add_response 'yes'
          assert_current_node :do_you_have_a_disability_or_health_condition?
        end

        should "ask if you are in financial hardship" do
          add_response 'yes'
          add_response 'no'
          add_response 'yes'
          assert_current_node :are_you_in_financial_hardship?
        end

        should "ask if you are studing a specific course" do
          add_response 'no'
          add_response 'no'
          add_response 'yes'
          add_response 'yes'
          assert_current_node :are_you_studying_one_of_these_courses?
        end

        context "assigning additional grants" do
          should "children, dependant adults, and social-work" do
            add_response 'yes'
            add_response 'yes'
            add_response 'no'
            add_response 'no'
            add_response 'social-work'
            assert_current_node :done
            assert_phrase_list :additional_benefits, [:body, :dependent_children, :dependent_adult, :social_work]
          end

          should "dependent adult, disability, and no course" do
            add_response 'no'
            add_response 'yes'
            add_response 'yes'
            add_response 'no'
            add_response 'none'
            assert_current_node :done
            assert_phrase_list :additional_benefits, [:body, :dependent_adult, :disability]
          end

          should "everything, and teacher training" do
            add_response 'yes'
            add_response 'yes'
            add_response 'yes'
            add_response 'yes'
            add_response 'teacher-training'
            assert_current_node :done
            assert_phrase_list :additional_benefits, [:body, :dependent_children, :dependent_adult, :disability, :financial_hardship, :teacher_training]
          end
        end
      end # checking for grants etc.


    end # full-time student

    context "part-time student" do
      setup do
        add_response 'part-time'
      end

      should "ask how much your tuition fees are per year" do
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end

      should "be invalid if a fee over 6750 is entered" do
        add_response '6751'
        assert_current_node_is_error
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end

      context "with valid fees entered" do
        setup do
          add_response '6549'
        end

        should "ask if you want to check for additional grants etc." do
          assert_current_node :part_time_do_you_want_to_check_for_additional_grants_and_allowances?
        end

        should "be done if not checking for grants" do
          add_response 'no'

          assert_current_node :done
          assert_phrase_list :eligible_finance, [:tuition_fee_loan]
          assert_state_variable :tuition_fee_amount, 6549
          assert_phrase_list :additional_benefits, []
          assert_phrase_list :extra_grants, [:additional_grants_and_allowances]
        end

        context "checking for additional grants" do
          setup do
            add_response 'yes'
          end

          should "ask if you have a disability" do
            assert_current_node :do_you_have_a_disability_or_health_condition?
            assert_phrase_list :extra_grants, []
          end

          should "ask if you are in financial hardship" do
            add_response 'yes'
            assert_current_node :are_you_in_financial_hardship?
          end

          should "ask if you are studing a specific course" do
            add_response 'no'
            add_response 'yes'
            assert_current_node :are_you_studying_one_of_these_courses?
          end

          context "assigning additional grants" do
            should "disability, and medical course" do
              add_response 'yes'
              add_response 'no'
              add_response 'dental-medical-or-healthcare'
              assert_current_node :done
              assert_phrase_list :additional_benefits, [:body, :disability, :medical]
            end

            should "disability, financial hardship, and no course" do
              add_response 'yes'
              add_response 'yes'
              add_response 'none'
              assert_current_node :done
              assert_phrase_list :additional_benefits, [:body, :disability, :financial_hardship]
            end

            should "teacher-training course" do
              add_response 'no'
              add_response 'no'
              add_response 'teacher-training'
              assert_current_node :done
              assert_phrase_list :additional_benefits, [:body, :teacher_training]
            end
          end
        end # checking for grants etc.
      end # valid fees
    end # part-time student
  end # when course starts

  context "course starting between 2013 and 2014" do
    setup do
      add_response '2013-2014'
    end

    should "ask if you are full-time or part-time student" do
      assert_current_node :are_you_a_full_time_or_part_time_student?
    end

    context "full-time student between 2013 and 2014" do
      setup do
        add_response 'full-time'
      end

      should "ask how much your tuition fees are per year" do
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end

      should "be invalid if a fee over 9000 is entered" do
        add_response '9001'
        assert_current_node_is_error
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end

      context "with valid fees entered" do
        setup do
          add_response '8490'
        end

        should "ask where you will live while studying" do
          assert_current_node :where_will_you_live_while_studying?
        end

        context "living at home" do
          setup do
            add_response 'at-home'
          end

          should "ask whats your household income" do
            assert_current_node :whats_your_household_income?
          end

          context "household income up to 25k" do
            setup do
              add_response '23999'
            end

            should "ask if you want to check for additional grants etc" do
              assert_current_node :full_time_do_you_want_to_check_for_additional_grants_and_allowances?
            end

            should "be done if not checking for additional grants etc. and grant amounts should be for 2013-2014 period" do
              add_response 'no'

              assert_current_node :done
              assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan, :maintenance_grant]
              assert_state_variable :tuition_fee_amount, 8490
              assert_state_variable :maintenance_loan_amount, 2698 #4375 - (maintenance_grant_amount/2.0).floor
              assert_state_variable :maintenance_grant_amount, 3354
              assert_phrase_list :additional_benefits, []
            end
          end

          context "household income at 30k and not checking additional grants" do
            setup do
              add_response '30000'
              add_response 'no'
            end

            should "be done and display correct maintenance grant and loan amount" do
              assert_current_node :done
              assert_state_variable :maintenance_grant_amount, 2416
              assert_state_variable :maintenance_loan_amount, 3167
            end
          end

          context "household income at 40k and not checking additional grants" do
            setup do
              add_response '40000'
              add_response 'no'
            end

            should "be done and display correct maintenance grant and loan amount" do
              assert_current_node :done
              assert_state_variable :maintenance_grant_amount, 540
              assert_state_variable :maintenance_loan_amount, 4105
            end
          end

          context "household income at 42611 and not checking additional grants" do
            setup do
              add_response '42611'
              add_response 'no'
            end

            should "be done and display correct maintenance grant and loan amount" do
              assert_current_node :done
              assert_state_variable :maintenance_grant_amount, 50
              assert_state_variable :maintenance_loan_amount, 4350
            end
          end

          context "household income at 60000 and not checking additional grants" do
            setup do
              add_response '60000'
              add_response 'no'
            end

            should "be done and display correct maintenance grant and loan amount" do
              assert_current_node :done
              assert_state_variable :maintenance_grant_amount, 0
              assert_state_variable :maintenance_loan_amount, 2843
            end
          end

        end # living at home

        # test grant and loan amounts for living away from home outside London
        context "living away from home, outside London" do
          setup do
            add_response 'away-outside-london'
          end

          should "ask whats your household income" do
            assert_current_node :whats_your_household_income?
          end

          should "display correct grant and loan amount for under £25k" do
            add_response 22000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 3354
            assert_state_variable :maintenance_loan_amount, 3823
          end


          should "display correct grant and loan amount for 42611" do
            add_response 42611
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 50
            assert_state_variable :maintenance_loan_amount, 5475
          end          

          should "display correct grant and loan amount for 42612" do
            add_response 42612
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 5500
          end

          should "display correct min loan amount for 65k" do
            add_response 65000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 3575
          end


        end # away from home, outside London


        # test grant and loan amounts living away from home in London
        context "living away from home, in London" do
          setup do
            add_response 'away-in-london'
          end

          should "ask whats your household income" do
            assert_current_node :whats_your_household_income?
          end

          should "display correct grant and loan amount for under £25k" do
            add_response 22000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 3354
            assert_state_variable :maintenance_loan_amount, 5998
          end


          should "display correct grant and loan amount for 42611" do
            add_response 42611
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 50
            assert_state_variable :maintenance_loan_amount, 7650
          end          

          should "display correct grant and loan amount for 42612" do
            add_response 42612
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 7675
          end

          should "display correct loan amount for 65k" do
            add_response 65000
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 5463
          end

          should "display correct min amount for 69745" do
            add_response 69745
            add_response 'no'

            assert_current_node :done
            assert_state_variable :maintenance_grant_amount, 0
            assert_state_variable :maintenance_loan_amount, 4988
          end

        end # away from home, in london

      end # valid fees
    end # part-time student
  end # when course starts
end
