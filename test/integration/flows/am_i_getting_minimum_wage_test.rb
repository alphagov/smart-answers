require_relative "../../test_helper"
require_relative "flow_test_helper"

class AmIGettingMinimumWageTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "am-i-getting-minimum-wage"
  end
  
  # Q1
  should "ask 'what would you like to check?'" do
    assert_current_node :what_would_you_like_to_check?
  end
  
  context "when checking current pay" do
    setup do
      add_response :current_payment
    end
    
    # Q2
    should "ask 'are you an apprentice?'" do
      assert_current_node :are_you_an_apprentice?
    end
    
    context "answered 'apprentice under 19' to 'are you an apprentice?'" do
      setup do
        add_response :apprentice_over_19
      end
      should "ask 'how often do you get paid?'" do
        assert_current_node :how_often_do_you_get_paid?
      end
    end
    
    context "answered 'apprentice over 19' to 'are you an apprentice?'" do
      setup do
        add_response :apprentice_over_19
      end
      should "ask 'how often do you get paid?'" do
        assert_current_node :how_often_do_you_get_paid?
      end
      
    end
    
    context "answered 'no' to 'are you an apprentice?'" do
      # Q3
      
      setup do
        add_response :no
      end
      
      should "ask 'how old are you?'" do
        assert_current_node :how_old_are_you?
      end
      
      context "answered 19 to 'how old are you?'" do
        setup do
          add_response 19
        end
      
        # Q4
        should "ask 'how often do you get paid?'" do
          assert_current_node :how_often_do_you_get_paid?
        end
        
        context "answered weekly to 'how often do you get paid?'" do
          setup do
            add_response "7"
          end
          
          # Q5
          should "ask 'how many hours do you work?'" do
            assert_current_node :how_many_hours_do_you_work?
          end
          
          context "answered 'how many hours do you work?'" do
            setup do
              @basic_hours = 42
              add_response @basic_hours
            end
            
            # Q6
            should "ask 'how much do you get paid?'" do
              assert_current_node :how_much_are_you_paid_during_pay_period?
            end
            
            context "answered 158.39 to 'how much do you get paid?'" do
              setup do
                @initial_total_basic_pay = 158.39
                add_response @initial_total_basic_pay
              end

              should "calculate basic pay hourly rate" do
                assert_state_variable("basic_hourly_rate", 3.77)
              end
              
              # Q7
              should "ask 'how many hours overtime?'" do
                assert_current_node :how_many_hours_overtime_do_you_work?
              end
              
              context "answer '8 hours' to 'how many hours overtime?'" do
                setup do
                  @overtime_hours = 8
                  @total_hours = (@basic_hours + @overtime_hours).round(2)
                  add_response @overtime_hours
                end
                
                should "calculate the total number of hours worked" do
                  assert_state_variable("total_hours", @total_hours)
                end
                
                # Q8
                should "ask 'what rate of overtime per hour?'" do
                  assert_current_node :what_is_overtime_pay_per_hour?
                end
                
                context "answer 4.59 to 'overtime per hour?'" do
                  setup do
                    add_response 4.59
                  end
                  
                  should "calculate the total overtime pay" do
                    assert_state_variable("total_overtime_pay", 36.72)
                  end
                  
                  should "add the total overtime pay to the total basic pay" do
                    assert_state_variable("total_basic_pay", 195.11)
                  end
                end
                
                context "answer 3.71 to 'overtime per hour?'" do
                  setup do
                    add_response 3.71
                  end
                  should "calculate the overtime pay using the lesser value from basic and overtime rates." do
                    assert_state_variable("total_overtime_pay", 30.16)
                  end
                  
                  should "add the total overtime pay to the total basic pay" do
                    assert_state_variable("total_basic_pay", 188.55)
                  end
                  
                  should "calculate the total hourly rate" do
                    assert_state_variable("total_hourly_rate", (188.55 / @total_hours).round(2))
                  end
                  
                  # Quick calculation check(s) to ascertain basic + overtime + accommodation adjustments.
                  # Full scenarios are tested below.
                  #
                  context "also stays in free accommodation for 4 nights" do
                    setup do
                      add_response :yes_free
                      add_response 4
                    end
                    
                    should "adjust the total basic pay for free accommodation" do
                      accommodation_adjustment = (4.73 * 4).round(2)
                      assert_state_variable("total_basic_pay", 188.55 + accommodation_adjustment)
                    end
                  end
                  
                  context "also stays in charged accommodation for 4 nights" do
                    setup do
                      add_response :yes_charged
                      add_response 7.89
                      add_response 4
                    end
                    
                    should "adjust the total basic pay for charged accommodation" do
                      free_adjustment = (4.73 * 4).round(2)
                      charged_adjustment = (7.89 * 4).round(2)
                      assert_state_variable("total_basic_pay", 188.55 + (free_adjustment - charged_adjustment).round(2))
                    end
                  end
                  
                end              
              end
              
              context "answer 'no overtime' to 'how many hours overtime?'" do
                setup do
                  add_response 0
                end
                
                # Q9
                should "ask 'are you provided with accommodation?'" do
                  assert_current_node :is_provided_with_accommodation?
                end
              
                context "answer 'no' to 'are you provided with accommodation?'" do
                  setup do
                    add_response :no
                  end
                  
                  should "make no adjustment for accommodation" do
                    assert_state_variable("total_basic_pay", @initial_total_basic_pay.to_s)
                  end
                  
                  should "show the results" do
                    assert_current_node :current_payment
                  end
                end
                
                # Where accommodation is charged under the £4.73 threshold.
                # No adjustment is made to basic pay.
                #
                context "answer 'yes charged accommodation' to 'are you provided with accommodation?'" do
                  setup do
                    add_response :yes_charged
                  end
                  
                  # Q10
                  should "ask 'how much do you pay for the accommodation?'" do
                    assert_current_node :current_accommodation_charge?
                  end
                  
                  context "answer 4.72 to 'how much do you pay for accommodation?'" do
                    setup do
                      add_response 4.72
                    end
                    
                    should "ask 'how often do you use the accommodation?'" do
                      assert_current_node :current_accommodation_usage?
                    end
                    
                    context "answer 4 to 'how often do you use the accommodation?'" do
                      setup do
                        add_response 4
                      end
                      
                      should "make no adjustment for charged accommodation" do
                        assert_state_variable("total_basic_pay", @initial_total_basic_pay)
                      end
                    end
                  end
                  
                  # Where accommodation is charged above the £4.73 threshold.
                  # Adjustment is made to basic pay.
                  #                
                  context "answer 7.35 to 'how much do you pay for accommodation?'" do
                    setup do
                      add_response 7.35
                    end
                    
                    should "ask 'how often do you use the accommodation?'" do
                      assert_current_node :current_accommodation_usage?
                    end
                    
                    context "answer 4 to 'how often do you use the accommodation?'" do
                      setup do
                        add_response 4
                        free_adjustment = (4.73 * 4).round(2)
                        charged_adjustment = (7.35 * 4).round(2)
                        @total_basic_pay = @initial_total_basic_pay + (free_adjustment - charged_adjustment)
                      end
                      
                      should "make the adjustment for charged accommodation" do
                        assert_state_variable("total_basic_pay", @total_basic_pay)
                      end
                      
                      should "calculate the total hourly rate" do
                        assert_state_variable("total_hourly_rate", (@total_basic_pay / @basic_hours).round(2))
                      end
                      
                    end
                  end
                end

                # Where accommodation is free.
                # Adjustment is made to basic pay at £4.73 x number of days in accommodation.
                #
                context "answer 'yes free accommodation' to 'are you provided with accommodation?'" do
                  setup do
                    add_response :yes_free
                  end
                  
                  # Q11
                  should "ask 'how often do you stay in the accommodation?'" do
                    assert_current_node :current_accommodation_usage?
                  end
                  
                  context "answer 3 to 'how often do you use the accommodation?'" do
                    setup do
                      add_response 3
                    end
                    should "make the adjustment for free accommodation" do
                      free_accommodation_adjustment = (4.73 * 3).round(2)
                      total_basic_pay = @initial_total_basic_pay + free_accommodation_adjustment
                      assert_state_variable("total_basic_pay", total_basic_pay)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end 
  end
  
  context "when checking past pay" do
    setup do
      add_response :past_payment
    end
    
    should "ask 'which year do you want to check?'" do
      assert_current_node :past_payment_year?
    end
    
    context "answer check payments for '2009', not an apprentice, aged '19'" do
      setup do
        add_response 2009
        add_response :no
        add_response 19
        add_response 7
        add_response 38
        add_response 157.65
        add_response 9
      end
      
      should "calculate the historical total pay" do
        assert_state_variable("historical_entitlement", 227.01)
      end
    end
    
    context "answer check payments for '2009', apprentice" do
      setup do
        add_response 2009
        add_response :apprentice_over_19
        add_response 7
        add_response 40
        add_response 80.98
        add_response 7
      end
      
      should "calculate the historical total pay" do
        assert_current_node :what_was_overtime_pay_per_hour?
        assert_state_variable("historical_entitlement", 0)
      end
    end
    
  end
end
