# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class StudentFinanceFormsTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'student-finance-forms'
  end

  should "ask what type of student you are" do
    assert_current_node :type_of_student?
  end

  context "UK student full time" do
    setup do
      add_response 'uk-full-time'
    end

    should "ask what you need the form for" do
      assert_current_node :form_needed_for_1?
    end

    context "apply for student loans and grants" do
      setup do
        add_response 'apply-loans-grants'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      context "2013 to 2014" do
        setup do
          add_response 'year-1314'
        end

        should "ask are you a continuing student" do
          assert_current_node :continuing_student?
        end

        should "continuing student = yes" do
          add_response 'continuing-student'
          assert_current_node :outcome_2
          assert_phrase_list :form_destination, [:postal_address_uk]
        end

        should "continuing student = no" do
          add_response 'new-student'
          assert_current_node :outcome_1
          assert_phrase_list :form_destination, [:postal_address_uk]
        end
      end 

      context "2012 to 2013" do
        setup do
          add_response 'year-1213'
        end

        should "ask are you a continuing student" do
          assert_current_node :continuing_student?
        end

        should "continuing student = yes" do
          add_response 'continuing-student'
          assert_current_node :outcome_4
          assert_phrase_list :form_destination, [:postal_address_uk]
        end

        should "continuing student = no" do
          add_response 'new-student'
          assert_current_node :outcome_3
          assert_phrase_list :form_destination, [:postal_address_uk]
        end
      end 
    end 

    context "send proof of identity" do
      setup do
        add_response 'proof-identity'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_13
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2012/13" do
        add_response 'year-1213'
        assert_current_node :outcome_14
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end 
  
    context "send parents or partners details" do
      setup do
        add_response 'income-details'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_11
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2012/13" do
        add_response 'year-1213'
        assert_current_node :outcome_12
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end 
  
    context "apply DSA" do
      setup do
        add_response 'apply-dsa'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_15
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2012/13" do
        add_response 'year-1213'
        assert_current_node :outcome_16
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end 

    context "claim DSA expenses" do
      setup do
        add_response 'dsa-expenses'
        assert_current_node :outcome_19
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end 

    context "claim CcG" do
      setup do
        add_response 'apply-ccg'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_17
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2012/13" do
        add_response 'year-1213'
        assert_current_node :outcome_18
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end 

    context "claim CcG expenses" do
      setup do
        add_response 'ccg-expenses'
        assert_current_node :outcome_20
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end 

    context "claim travel grants" do
      setup do
        add_response 'travel-grant'
        assert_current_node :outcome_21
      end
    end 
  end 


  context "UK student part time" do
    setup do
      add_response 'uk-part-time'
    end

    should "ask what you need the form for" do
      assert_current_node :form_needed_for_2?
    end

    context "apply for student loans and grants" do
      setup do
        add_response 'apply-loans-grants'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

        context "2013 to 2014" do
          setup do
            add_response 'year-1314'
          end

          should "ask are you a continuing student" do
            assert_current_node :continuing_student?
          end

          context "continuing student = yes" do
            setup do
              add_response 'continuing-student'
            end

            should "course start before 01/09/12" do
              add_response 'course-start-before-01092012'
              assert_current_node :outcome_7
              assert_phrase_list :form_destination, [:postal_address_uk]
            end

            should "course start after 01/09/12" do
              add_response 'course-start-after-01092012'
              assert_current_node :outcome_6
              assert_phrase_list :form_destination, [:postal_address_uk]
            end
          end 

          context "continuing student = no" do
            setup do
              add_response 'new-student'
            end

            should "course start before 01/09/12" do
              add_response 'course-start-before-01092012'
              assert_current_node :outcome_7
              assert_phrase_list :form_destination, [:postal_address_uk]
            end

            should "course start after 01/09/12" do
              add_response 'course-start-after-01092012'
              assert_current_node :outcome_5
              assert_phrase_list :form_destination, [:postal_address_uk]
            end
          end 
        end
        
        context "2012 to 2013" do
          setup do
            add_response 'year-1213'
          end

          should "ask are you a continuing student" do
            assert_current_node :continuing_student?
          end

          context "continuing student = yes" do
            setup do
              add_response 'continuing-student'
            end

            should "course start before 01/09/12" do
              add_response 'course-start-before-01092012'
              assert_current_node :outcome_10
              assert_phrase_list :form_destination, [:postal_address_uk]
            end

            should "course start after 01/09/12" do
              add_response 'course-start-after-01092012'
              assert_current_node :outcome_9
              assert_phrase_list :form_destination, [:postal_address_uk]
            end
          end 

          context "continuing student = no" do
            setup do
              add_response 'new-student'
            end

          should "course start before 01/09/12" do
            add_response 'course-start-before-01092012'
            assert_current_node :outcome_10
            assert_phrase_list :form_destination, [:postal_address_uk]
          end

          should "course start after 01/09/12" do
            add_response 'course-start-after-01092012'
            assert_current_node :outcome_8
            assert_phrase_list :form_destination, [:postal_address_uk]
          end
        end
      end
    end

    context "send proof of identity" do
      setup do
        add_response 'proof-identity'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end
      
      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_13
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2012/13" do
        add_response 'year-1213'
        assert_current_node :outcome_14
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "apply DSA" do
      setup do
        add_response 'apply-dsa'
        assert_current_node :outcome_20
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "claim DSA expenses" do
      setup do
        add_response 'dsa-expenses'
        assert_current_node :outcome_21
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end
  end

  context "EU student full time" do
    setup do
      add_response 'eu-full-time'
    end

    should "ask what year you want funding for" do
      assert_current_node :what_year?
    end

    context "2013 to 2014" do
      setup do
        add_response 'year-1314'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response 'continuing-student'
        assert_current_node :outcome_23
        assert_phrase_list :form_destination, [:postal_address_eu]
      end

      should "continuing student = no" do
        add_response 'new-student'
        assert_current_node :outcome_22
        assert_phrase_list :form_destination, [:postal_address_eu]
      end
    end 

    context "2012 to 2013" do
      setup do
        add_response 'year-1213'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response 'continuing-student'
        assert_current_node :outcome_27
        assert_phrase_list :form_destination, [:postal_address_eu]
      end

      should "continuing student = no" do
        add_response 'new-student'
        assert_current_node :outcome_26
        assert_phrase_list :form_destination, [:postal_address_eu]
      end
    end
  end
 
  context "EU student part time" do
    setup do
      add_response 'eu-part-time'
    end

    should "ask what year you want funding for" do
      assert_current_node :what_year?
    end

    context "2013 to 2014" do
      setup do
        add_response 'year-1314'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response 'continuing-student'
        assert_current_node :outcome_25
        assert_phrase_list :form_destination, [:postal_address_eu]
      end

      should "continuing student = no" do
        add_response 'new-student'
        assert_current_node :outcome_24
        assert_phrase_list :form_destination, [:postal_address_eu]
      end
    end 

    context "2012 to 2013" do
      setup do
        add_response 'year-1213'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response 'continuing-student'
        assert_current_node :outcome_29
        assert_phrase_list :form_destination, [:postal_address_eu]
      end

      should "continuing student = no" do
        add_response 'new-student'
        assert_current_node :outcome_28
        assert_phrase_list :form_destination, [:postal_address_eu]
      end
    end
  end
end


