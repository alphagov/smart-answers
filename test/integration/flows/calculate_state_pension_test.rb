require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatePensionTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-state-pension'
  end

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
          assert_state_variable "remaining_years", 27
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
            
            should "ask for years of benefit" do
              assert_current_node :received_child_benefit?
            end
          end
        end
      end
      
      context "born between 1959-04-06 or 1992-04-05, not enough qualifying years, no child benefit" do
        should "return amount_result" do
          add_response Date.parse("8th October 1960")
          add_response 25
          add_response 1
          add_response :no
          assert_current_node :amount_result
        end
      end

      context "born after 6/10/1953 and 25 years of taxed income" do
        setup do
          add_response Date.parse("8th October 1953")
          add_response 25
        end

        context "not enough qualifying years" do
          setup do
            add_response 1
          end

          should "get to received_child_benefit?" do
            assert_current_node :received_child_benefit?
          end

          context "not received child benefit" do
            setup do
              add_response :no
            end

            should "go to amount_result" do
              assert_current_node :years_of_work?
            end
          end

          context "yes have received child benefit" do
            setup do
              add_response :yes
            end

            should "go to years_of_benefit" do
              assert_current_node :years_of_benefit?
            end
          end

        end

        context "enough qualifying years" do
          should "get to received_child_benefit?" do
            add_response 5
            assert_current_node :amount_result
          end
        end
      end

      context "born before 6/10/1953" do
        setup do 
          add_response Date.parse("4th October 1953")
        end

        should "ask for number of years paid NI" do
          assert_current_node :years_paid_ni?
        end

        context "25 years of NI" do
          setup do
            add_response 25
          end

          should "ask for JSA years" do
            assert_current_node :years_of_jsa?
          end

          context "1 year of JSA" do
            setup do
              add_response 1
            end

            should "ask if you were employed between 60 and 64" do
              assert_state_variable "qualifying_years", 26
              assert_current_node :employed_between_60_and_64?
            end

            should "ask about child benefit on 'yes'" do
              add_response :yes
              assert_current_node :received_child_benefit?
            end

            context "answer no" do
              setup {add_response :no}

              should "ask about child benefit" do
                assert_state_variable "automatic_years", 1
                assert_state_variable "qualifying_years", 27
                assert_current_node :received_child_benefit?
              end

              context "yes received child benefit" do
                setup {add_response :yes}

                should "go to result 4 years" do
                  add_response 4
                  assert_current_node :amount_result
                end

                should "error on text entry" do
                  add_response 'four years'
                  assert_current_node_is_error
                end

                should "error on amount over 22" do
                  add_response 44
                  assert_current_node_is_error
                end

                context "add 2 years" do
                  setup do
                    add_response 2
                  end

                  should "go to years of care" do
                    assert_state_variable "qualifying_years", 29
                    assert_current_node :years_of_caring?
                  end
                end

                should "go to result on 4 years" do
                  add_response 4
                  assert_current_node :amount_result
                end
              end
            end
          end

        end
        
        context "NI = 20, JSA = 1, employed_between_60_and_64 = no, received_child_benefit = yes, years_of_benefit = 1, years_of_caring = 1" do
          setup do
            add_response 20
            add_response 1
            add_response :no
            add_response :yes
            add_response 1
          end

          should "be on years_of_caring" do
            assert_state_variable "qualifying_years", 23
            assert_current_node :years_of_caring?
          end

          context "answer 1 year" do
            setup do
              add_response 1
            end

            should "be on years_of_carers_allowance" do
              assert_state_variable "qualifying_years", 24
              assert_current_node :years_of_carers_allowance?
            end

            should "be on years_of_work" do
              add_response 1
              assert_state_variable "qualifying_years", 25
              assert_current_node :years_of_work?
            end
          end 

          should "throw error on years_of_caring = 3" do
            add_response 3
            assert_current_node_is_error
          end
        end
      end

      context "born 5 Apr 1952 - automatic_years test" do
        setup do
          add_response Date.parse("5th April 1952")
          add_response 25
        end

        context "not enough qualifying years" do
          setup do
            add_response 1
          end
          should "return auto years 3" do
            add_response :no
            assert_state_variable "automatic_years", 3
                # assert_state_variable "qualifying_years", 
            assert_current_node :received_child_benefit?
          end

          should "return auto years 0" do
            add_response :yes
            assert_state_variable "automatic_years", 0
            assert_current_node :received_child_benefit?
          end
        end

        context "enough qualifying years with automatic_years" do
          setup do
            add_response 2
            add_response :no
          end
            
          should "return amount_result and auto years 3" do
            assert_current_node :amount_result
            assert_state_variable :automatic_years, 3
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

              # should "ask for years working or education" do
              should "ask id received child benefit" do
                assert_current_node :received_child_benefit?
              end

              context "1 year working or education" do
                should "show the result" do
                  add_response 1
                  assert_current_node :received_child_benefit?
                end #show result
              end #years working or education
            end #years of benefit
          end #years of jsa
        end #years of NI
      end # years old
      # context "answer born Jan 1st 1970" do
      #   setup do
      #     add_response Date.parse('1970-01-01')
      #     add_response 20
      #     add_response 0
      #     add_response 0
      #   end
        
      #   should "add 3 years credit for a person born between 1959 and 1992" do
      #     assert_state_variable "remaining_contribution_years", "7 years"
      #   end
      # end
      # context "answer born Jan 1st 1959" do
      #   setup do
      #     add_response Date.parse('1959-01-01')
      #     add_response 20
      #     add_response 4
      #     add_response 2
      #     add_response 1
      #   end
        
      #   should "add 2 years credit for a person born between April 1958 and April 1959" do
      #     assert_state_variable "remaining_contribution_years", "2 years"
      #   end
      # end
      # context "answer born December 1st 1957" do
      #   setup do
      #     add_response Date.parse('1957-12-01')
      #     add_response 20
      #     add_response 0
      #     add_response 0
      #     add_response 0
      #   end
        
      #   should "add 1 year credit for a person born between April 1957 and April 1958" do
      #     assert_state_variable "remaining_contribution_years", "9 years"
      #   end
      # end
    end # gender
  end #amount calculation
end #ask which calculation
