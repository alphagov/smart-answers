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

      context "pension_credit_date check -- born 5th Dec 1953" do
        setup{ add_response Date.parse("5th Dec 1953")}
        should "go to age result" do
          assert_current_node :age_result
          assert_state_variable :state_pension_date, Date.parse("05 Dec 2018")
          assert_state_variable :pension_credit_date, Date.parse("06 Nov 2018").strftime("%e %B %Y")
        end
      end

      context "born on 6th April 1945" do
        setup do
          add_response Date.parse("6th April 1945")
        end

        should "give an answer" do
          assert_current_node :age_result
          assert_phrase_list :tense_specific_title, [:have_reached_pension_age]
          assert_phrase_list :state_pension_age_statement, [:state_pension_age_was]
          assert_state_variable "state_pension_age", "65 years"
          assert_state_variable "formatted_state_pension_date", " 6 April 2010"
          assert_state_variable "formatted_pension_pack_date", "December 2009"
        end
      end # born on 6th of April
    end # male

    context "female, born on 4 August 1951" do 
      setup do
        Timecop.freeze('2012-10-08') do
          add_response :female
          add_response Date.parse("4th August 1951")
        end
      
        should "tell them they are within four months and four days of state pension age" do
          assert_current_node :near_state_pension_age
          assert_state_variable "formatted_state_pension_date", " 6 November 2012"
        end 
      end
    end
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

    context "male" do
      setup {add_response :male}

      should "ask for date of birth" do
        assert_current_node :dob_amount?
      end

      context "within four months and four days of state pension age test" do
        setup do
          Timecop.freeze('2012-10-08') do
            add_response Date.parse('1948-02-12')
          end
        end

        should "display near state pension age response" do
          assert_current_node :near_state_pension_age
        end
      end

      context "four months and five days from state pension age test" do
        setup do 
          Timecop.freeze('2012-10-08') do
            add_response Date.parse('1948-02-13')
          end
          
          should "ask for years paid ni" do
            assert_current_node :years_paid_ni
          end
        end
      end

      context "born before 6/10/1953" do
        setup do 
          add_response Date.parse("4th October 1953")
        end

        should "ask for number of years paid NI" do
          assert_state_variable "state_pension_age", "65 years"
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

            should "ask about child benefit " do
              assert_state_variable "qualifying_years", 26
              assert_current_node :received_child_benefit?
            end

            context "yes to child benefit" do
              setup do
                add_response :yes
              end

              should "ask for years of child benefit" do 
                assert_current_node :years_of_benefit?
              end

              context "4 years of child benefit" do
                setup do
                  add_response 4
                end

                should "go to amount_result" do
                  assert_state_variable "qualifying_years_total", 30
                  assert_current_node :amount_result
                end
              end # 4 years of child benefit

              should "error on text entry" do
                add_response 'four years'
                assert_current_node_is_error
              end

              should "error on amount over 22" do
                add_response 44
                assert_current_node_is_error
              end

              context "add 2 years of child benefit" do
                setup do
                  add_response 2
                end

                should "go to years of care" do
                  assert_state_variable "qualifying_years", 28
                  assert_current_node :years_of_caring?
                end
              end # 2 years if child benefit

              context "0 years of child benefit" do
                setup {add_response 0}

                should "go to years of caring" do
                  assert_state_variable "qualifying_years", 26
                  assert_current_node :years_of_caring?
                end

                context "0 years_of_caring" do
                  setup {add_response 0}

                  should "go to years_of_carers_allowance" do
                    assert_current_node :years_of_carers_allowance?
                  end

                  context "0 years_of_carers_allowance" do
                    setup {add_response 0}

                    should "go years_of_work" do
                      assert_current_node :years_of_work?
                    end

                    context "0 years_of_work" do
                      setup {add_response 0}

                      should "go to amount_result" do
                        assert_state_variable "qualifying_years", 26
                        assert_state_variable "qualifying_years_total", 26
                        assert_state_variable "missing_years", 4
                        # 26/30 * 107.45
                        assert_state_variable "pension_amount", "93.12"
                        assert_state_variable "state_pension_age", "65 years"
                        assert_state_variable "remaining_years", 6
                        assert_state_variable "pension_loss", "14.33"
                        assert_phrase_list :result_text, [:too_few_qy_enough_remaining_years, :automatic_years_phrase]
                        assert_state_variable "state_pension_date", Date.parse("2018 Oct 4th")
                        assert_current_node :amount_result
                      end
                    end #work                     
                  end #carers allowance
                end # caring
              end # 0 years of child benefit
            end # yes to child benefit
          end # 1 year of JSA
        end # 25 years of NI

        context "NI = 20, JSA = 1 received_child_benefit = yes, years_of_benefit = 1, years_of_caring = 1" do
          setup do
            add_response 20
            add_response 1
            add_response :yes
            add_response 1
          end

          should "be on years_of_caring" do
            assert_state_variable "qualifying_years", 22
            assert_current_node :years_of_caring?
          end

          context "answer 1 year" do
            setup do
              add_response 1
            end

            should "be on years_of_carers_allowance" do
              assert_state_variable "qualifying_years", 23
              assert_current_node :years_of_carers_allowance?
            end

            should "be on years_of_work" do
              add_response 1
              assert_state_variable "qualifying_years", 24
              assert_current_node :years_of_work?
            end
          end 

          # FIXME Time-sensitive - from April 2013 3 will be possible
          should "throw error on years_of_caring = 3" do
            add_response 3
            assert_current_node_is_error
          end
        end # ni=20, jsa=1, etc...
      end # born before 6/10/1953

      context "age 61, NI = 15 (testing years_of_jsa errors)" do
        setup do
          add_response 61.years.ago
          add_response 15
        end

        should "error when entering more than 27" do
          add_response 28
          assert_current_node_is_error
        end

        should "pass when entering 7" do
          add_response 7
          assert_current_node :received_child_benefit?
        end
      end # 61, ni=15, etc

      context "age = 61, NI = 20, JSA = 1" do
        setup do
          Timecop.freeze("2012-08-08") do
            add_response 61.years.ago
            add_response 20
            add_response 1
          end
        end

        should "go to received_child_benefit?" do
          assert_state_variable "available_ni_years", 21
          assert_state_variable "qualifying_years", 21
          assert_current_node :received_child_benefit?
        end

        context "answer yes" do 
          setup {add_response :yes}

          should "be at years_of_benefit" do
            assert_current_node :years_of_benefit?
          end

          should "error if 23 years entered" do
            add_response 23
            assert_current_node_is_error
          end

          should "show result if 17 years entered" do
            add_response 17
            assert_current_node :amount_result
          end

          context "2 years of benefit" do
            setup {add_response 2}

            should "available_ni_years = 19, qualifying_years = 23" do
              assert_state_variable "available_ni_years", 19
              assert_state_variable "qualifying_years", 23
              assert_current_node :years_of_caring?
            end
          end
        end
      end # 61, ni=10, jsa=1, etc

    end # male


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

      context "50 years old" do
        setup do
          add_response 50.years.ago
        end

        should "ask for number of years paid NI" do
          assert_state_variable "remaining_years", 16
          assert_state_variable "available_ni_years", 31
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
            add_response 37
          end

          should "return error as they will only have available_ni_years of 21" do
            assert_current_node_is_error
          end
        end

        context "10 years of NI" do
          setup do
            add_response 10
          end

          should "ask for number of years claimed JSA" do
            assert_state_variable "available_ni_years", 21
            assert_current_node :years_of_jsa?
          end

          context "7 years of jsa" do
            should "show the result" do
              add_response 7
              assert_state_variable "available_ni_years", 14
              assert_current_node :received_child_benefit?
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
          add_response 25   # ni years
          add_response 1    # jsa years
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
          should "get to amount benefit" do
            add_response 5

            assert_current_node :amount_result
          end
        end
      end

      context "(testing from years_of_benefit) age 40, NI = 5, JSA = 5, cb = yes " do
        setup do
          add_response 40.years.ago
          add_response 10
          add_response 5
          add_response :yes
        end

        should "error when entering more than 6 (over available_ni_years limit)"  do
          add_response 7
          assert_current_node_is_error
        end

        should "pass when entering 6 (go to amount_result as available_ni_years is maxed)" do
          add_response 6
          assert_current_node :amount_result
        end

        context "answer 0" do
          setup {add_response 5}

          should "be at years_of_caring?" do
            assert_state_variable "available_ni_years", 1
            assert_current_node :years_of_caring?
          end

          should "fail on 2" do
            add_response 2
            assert_current_node_is_error
          end 

          should "pass when entering 1 (go to amount_result as available_ni_years is maxed)" do
            add_response 1
            assert_current_node :amount_result
          end

          context "answer 0" do
            setup {add_response 0}

            should "go to years_of_carers_allowance" do
              assert_state_variable "available_ni_years", 1
              assert_current_node :years_of_carers_allowance?
            end

            should "fail on 2" do
              add_response 2
              assert_current_node_is_error
            end 

            should "pass when entering 1 (go to amount_result as available_ni_years is maxed)" do
              add_response 1
              assert_current_node :amount_result
            end

            context "answer 0" do
              setup {add_response 0}

              should "got to years_of_work?" do
                assert_state_variable "available_ni_years", 1
                assert_current_node :amount_result
              end
            end
          end
        end
      end

      context "(testing from years_of_work) born in '58, NI = 10, JSA = 5, cb = no " do
        setup do
          add_response Date.parse("5th May 1958")
          add_response 22
          add_response 7
          add_response :no
        end

        should "be at years_of_work" do
          assert_current_node :years_of_work?
        end 

        should "return error on entering 4" do
          add_response 4
          assert_current_node_is_error
        end

        should "return amount_result on entering 3" do
          add_response 3
          assert_current_node :amount_result
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

      context "answer born Jan 1st 1970" do
        setup do
          add_response Date.parse('1970-01-01')
          add_response 20
          add_response 0
          add_response :no
        end
        
        should "add 3 years credit for a person born between 1959 and 1992" do
          assert_current_node :amount_result
          assert_state_variable "missing_years", 7
        end
      end

      context "answer born Jan 1st 1959" do
        setup do
          add_response Date.parse('1959-01-01')
          add_response 20
          add_response 4
          add_response :yes
          add_response 2
          add_response 1
          add_response 0
          add_response 0
        end
        
        should "add 2 years credit for a person born between April 1958 and April 1959" do
          assert_current_node :amount_result
          assert_state_variable "missing_years", 1
        end
      end
      context "answer born December 1st 1957" do
        setup do
          add_response Date.parse('1957-12-01')
          add_response 20
          add_response 0
          add_response :no
          add_response 0
        end
        
        should "add 1 year credit for a person born between April 1957 and April 1958" do
          assert_state_variable "missing_years", 9
        end
      end
      context "years_you_can_enter test" do
        setup do
          add_response 49.years.ago.to_s
          add_response 20
          add_response 5
          add_response :yes
        end
        
        should "return 5" do
          # add_response 0
          assert_state_variable "available_ni_years", 5
          assert_state_variable "years_you_can_enter", 5
          assert_current_node :years_of_benefit?
        end
      end
    end # gender
  end #amount calculation
end #ask which calculation
