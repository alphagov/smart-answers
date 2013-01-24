# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class StudentFinanceFormFinderTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'student-finance-forms'
  end

  should "ask what type of student you are" do
    assert_current_node :type_of_student?
  end

  context "UK student full time" do
    setup do
      add_response '1'
    end

    should "ask what you need the form for" do
      assert_current_node :form_needed_for_1?
    end

    context "apply for student loans and grants" do
      setup do
        add_response '1'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      context "2013 to 2014" do
        setup do
          add_response '1'
        end

        should "ask are you a continuing student" do
          assert_current_node :continuing_student?
        end

        should "continuing student = yes" do
          add_response '1'
          assert_current_node :outcome_2
        end

        should "continuing student = no" do
          add_response '2'
          assert_current_node :outcome_1
        end
      end #end uk_ft_apply_student_finance_1314

      context "2012 to 2013" do
        setup do
          add_response '2'
        end

        should "ask are you a continuing student" do
          assert_current_node :continuing_student?
        end

        should "continuing student = yes" do
          add_response '1'
          assert_current_node :outcome_4
        end

        should "continuing student = no" do
          add_response '2'
          assert_current_node :outcome_3
        end
      end #end uk_ft_apply_student_finance_1213
    end #end uk_ft_apply_student_finance

    context "send proof of identity" do
      setup do
        add_response '2'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response '1'
        assert_current_node :outcome_13
      end

      should "year = 2012/13" do
        add_response '2'
        assert_current_node :outcome_14
      end
    end #end uk_ft_proof_identity
  
    context "send parents or partners details" do
      setup do
        add_response '3'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response '1'
        assert_current_node :outcome_11
      end

      should "year = 2012/13" do
        add_response '2'
        assert_current_node :outcome_12
      end
    end #end uk_ft_parent_partner
  
    context "claim DSA" do
      setup do
        add_response '4'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response '1'
        assert_current_node :outcome_15
      end

      should "year = 2012/13" do
        add_response '2'
        assert_current_node :outcome_16
      end
    end #end uk_ft_apply_dsa

    context "claim DSA expenses" do
      setup do
        add_response '5'
        assert_current_node :outcome_19
      end
    end #end uk_ft_dsa_expenses

    context "claim CcG" do
      setup do
        add_response '6'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response '1'
        assert_current_node :outcome_17
      end

      should "year = 2012/13" do
        add_response '2'
        assert_current_node :outcome_18
      end
    end #end uk_ft_apply_ccg

    context "claim CcG expenses" do
      setup do
        add_response '7'
        assert_current_node :outcome_20
      end
    end #end uk_ft_ccg_expenses

    context "claim travel grants" do
      setup do
        add_response '8'
        assert_current_node :outcome_21
      end
    end #end uk_ft_travel
  end #end uk_ft


  context "UK student part time" do
    setup do
      add_response '2'
    end

    should "ask what you need the form for" do
      assert_current_node :form_needed_for_2?
    end

    context "apply for student loans and grants" do
      setup do
        add_response '1'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

        context "2013 to 2014" do
          setup do
            add_response '1'
          end

          should "ask are you a continuing student" do
            assert_current_node :continuing_student?
          end

          context "continuing student = yes" do
            setup do
              add_response '1'
            end

            should "course start before 01/09/12" do
              add_response '1'
              assert_current_node :outcome_7
            end

            should "course start after 01/09/12" do
              add_response '2'
              assert_current_node :outcome_6
            end
          end #end uk_pt_apply_student_finance_1314_continuing

          context "continuing student = no" do
            setup do
              add_response '2'
            end

            should "course start before 01/09/12" do
              add_response '1'
              assert_current_node :outcome_7
            end

            should "course start after 01/09/12" do
              add_response '2'
              assert_current_node :outcome_5
            end
          end #end uk_pt_apply_student_finance_new
        end
        
        context "2012 to 2013" do
          setup do
            add_response '2'
          end

          should "ask are you a continuing student" do
            assert_current_node :continuing_student?
          end

          context "continuing student = yes" do
            setup do
              add_response '1'
            end

            should "course start before 01/09/12" do
              add_response '1'
              assert_current_node :outcome_10
            end

            should "course start after 01/09/12" do
              add_response '2'
              assert_current_node :outcome_9
            end
          end #end uk_pt_apply_student_finance_1213_continuing

          context "continuing student = no" do
            setup do
              add_response '2'
            end

          should "course start before 01/09/12" do
            add_response '1'
            assert_current_node :outcome_10
          end

          should "course start after 01/09/12" do
            add_response '2'
            assert_current_node :outcome_8
          end
        end
      end
    end

    context "send proof of identity" do
      setup do
        add_response '2'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end
      
      should "year = 2013/14" do
        add_response '1'
        assert_current_node :outcome_13
      end

      should "year = 2012/13" do
        add_response '2'
        assert_current_node :outcome_14
      end
    end

    context "claim CcG expenses" do
      setup do
        add_response '3'
        assert_current_node :outcome_20
      end
    end

    context "claim travel grants" do
      setup do
        add_response '4'
        assert_current_node :outcome_21
      end
    end
  end

  context "EU student full time" do
    setup do
      add_response '3'
    end

    should "ask what year you want funding for" do
      assert_current_node :what_year?
    end

    context "2013 to 2014" do
      setup do
        add_response '1'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response '1'
        assert_current_node :outcome_23
      end

      should "continuing student = no" do
        add_response '2'
        assert_current_node :outcome_22
      end
    end 

    context "2012 to 2013" do
      setup do
        add_response '2'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response '1'
        assert_current_node :outcome_27
      end

      should "continuing student = no" do
        add_response '2'
        assert_current_node :outcome_26
      end
    end
  end
 
  context "EU student part time" do
    setup do
      add_response '4'
    end

    should "ask what year you want funding for" do
      assert_current_node :what_year?
    end

    context "2013 to 2014" do
      setup do
        add_response '1'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response '1'
        assert_current_node :outcome_25
      end

      should "continuing student = no" do
        add_response '2'
        assert_current_node :outcome_24
      end
    end 

    context "2012 to 2013" do
      setup do
        add_response '2'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response '1'
        assert_current_node :outcome_29
      end

      should "continuing student = no" do
        add_response '2'
        assert_current_node :outcome_28
      end
    end
  end
end
