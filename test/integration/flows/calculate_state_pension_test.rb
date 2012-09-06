require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatePensionTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-state-pension'
  end

  #Q0
  should "ask which calculation to perform" do
      assert_current_node :which_calculation?
  end

  #Age
  #
  context "age calculation" do
    setup do
      add_response :age
    end
    
    should "ask your gender" do
      assert_current_node :gender?
    end

    context "male" do
      setup do
        add_response :male
      end
    
      should "ask for date of birth" do
        assert_current_node :dob_age?
      end

      context "born on 6th April 1945" do
        setup do
          add_response Date.parse("6th April 1945")
        end

        should "give an answer" do
          assert_current_node :age_result
        end
      end # born on 6th of April
    end # male
  end # age calculation
  
  #Amount
  #  
  context "amount calculation" do
    setup do
      add_response :amount
    end

    should "ask your gender" do
      assert_current_node :gender?
    end

    context "female" do
      setup do
        add_response :female
      end
    
      should "ask for date of birth" do
        assert_current_node :dob_amount?
      end

      context "under 20 years old" do
        should "say not enough qualifying years" do
          add_response 5.years.ago
          assert_current_node :too_young
        end
      end

      context "90 years old" do
        should "say already reached state pension age" do
          add_response 90.years.ago
          assert_current_node :reached_state_pension_age
        end
      end

      context "40 years old" do
        setup do
          add_response 40.years.ago
        end

        should "ask for number of years paid NI" do
          assert_current_node :years_paid_ni?
        end

        context "30 years of NI" do
          should "show the result" do
            add_response 30
            assert_current_node :amount_result
          end
        end

        context "27 years of NI" do
          setup do
            add_response 27
          end

          should "ask for number of years claimed JSA" do
            assert_current_node :years_of_jsa?
          end

          context "10 years of jsa" do
            should "show the result" do
              add_response 10
              assert_current_node :amount_result
            end
          end

          context "1 year of jsa" do
            setup do
              add_response 1
            end
            
            # The benefits question is skipped 
            # because of automatic age related credits
            should "ask for years of benefit" do
              assert_current_node :years_of_work?
            end
          end
        end
      end
      
      ## Too old for automatic age related credits.
      context "58 years old" do
        setup do
          add_response 58.years.ago
        end
        
        should "ask for number of years paid NI" do
          assert_current_node :years_paid_ni?
        end

        context "30 years of NI" do
          should "show the result" do
            add_response 30
            assert_current_node :amount_result
          end
        end

        context "27 years of NI" do
          setup do
            add_response 27
          end

          should "ask for number of years claimed JSA" do
            assert_current_node :years_of_jsa?
          end

          context "10 years of jsa" do
            should "show the result" do
              add_response 10
              assert_current_node :amount_result
            end
          end

          context "1 year of jsa" do
            setup do
              add_response 1
            end
            
            context "1 year of benefit" do
              setup do
                add_response 1
              end

              should "ask for years working or education" do
                assert_current_node :years_of_work?
              end

              context "1 year working or education" do
                should "show the result" do
                  add_response 1
                  assert_current_node :amount_result
                end #show result
              end #years working or education
            end #years of benefit
          end #years of jsa
        end #years of NI
      end # years old
      context "answer born Jan 1st 1970" do
        setup do
          add_response Date.parse('1970-01-01')
          add_response 20
          add_response 0
          add_response 0
        end
        
        should "add 3 years credit for a person born between 1959 and 1992" do
          assert_state_variable "remaining_contribution_years", "7 years"
        end
      end
      context "answer born Jan 1st 1959" do
        setup do
          add_response Date.parse('1959-01-01')
          add_response 20
          add_response 0
          add_response 0
          add_response 0
        end
        
        should "add 2 years credit for a person born between April 1958 and April 1959" do
          assert_state_variable "remaining_contribution_years", "8 years"
        end
      end
      context "answer born December 1st 1957" do
        setup do
          add_response Date.parse('1957-12-01')
          add_response 20
          add_response 0
          add_response 0
          add_response 0
        end
        
        should "add 1 year credit for a person born between April 1957 and April 1958" do
          assert_state_variable "remaining_contribution_years", "9 years"
        end
      end
    end # gender
  end #amount calculation
end #ask which calculation
