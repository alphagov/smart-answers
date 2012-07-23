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
    
    context "answered 'no' to 'are you an apprentice?'" do
      # Q3
      should "ask 'how old are you?'" do
        add_response :no
        assert_current_node :how_old_are_you?
      end
    end
    
    context "answered 'apprentice under 19' to 'are you an apprentice?'" do
      # Q4
      should "ask 'how often do you get paid?'" do
        add_response :apprentice_under_19
        assert_current_node :pay_frequency?
      end
    end
    
    context "answered 'apprentice over 19' to 'are you an apprentice?'" do
      setup do
        add_response :apprentice_over_19
      end
    
      # Q4
      should "ask 'how often do you get paid?'" do
        assert_current_node :pay_frequency?
      end
      
      context "answered weekly to 'how often do you get paid?'" do
        setup do
          add_response "7"
        end
        
        # Q5
        should "ask 'how many hours do you work?'" do
          assert_current_node :hours_worked_during_the_pay_period?
        end
        
        context "answered 'how many hours do you work?'" do
          setup do
            add_response "42"
          end
          
          # Q6
          should "ask 'how much do you get paid?'" do
            assert_current_node :quantity_paid_during_pay_period?
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
              assert_current_node :hours_overtime_during_pay_period?
            end
            
            context "answer '8 hours' to 'how many hours overtime?'" do
              setup do
                add_response 8
              end
              
              # Q8
              should "ask 'what rate of overtime per hour?'" do
                assert_current_node :overtime_pay_per_hour?
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
              end
              
            end
            
            context "answer 'no overtime' to 'how many hours overtime?'" do
              setup do
                add_response 0
              end
              
              # Q9
              should "ask 'are you provided with accommodation?'" do
                assert_current_node :provided_with_accommodation?
              end
            
              context "answer 'no' to 'are you provided with accommodation?'" do
                setup do
                  add_response :no
                end
                
                should "make no adjustment for accommodation" do
                  assert_state_variable("total_basic_pay", @initial_total_basic_pay.to_s)
                end
                
                should "show the results" do
                  assert_current_node :results
                end
              end
              
              context "answer 'yes charged accommodation' to 'are you provided with accommodation?'" do
                setup do
                  add_response :yes_charged
                end
                
                # Q10
                should "ask 'how much do you pay for the accommodation?'" do
                  assert_current_node :accommodation_charge?
                end
                
                context "answer 7.35 to 'how much do you pay for accommodation?'" do
                  setup do
                    add_response 7.35
                  end
                  
                  should "ask 'how often do you use the accommodation?'" do
                    assert_current_node :accommodation_usage?
                  end
                  
                  context "answer 4 to 'how often do you use the accommodation?'" do
                    setup do
                      add_response 4
                    end
                    
                    should "make the adjustment for charged accommodation" do
                      free_accommodation_adjustment = (4.73 * 4).round(2)
                      charged_accommodation_adjustment = (7.35 * 4).round(2)
                      total_basic_pay = @initial_total_basic_pay + (free_accommodation_adjustment - charged_accommodation_adjustment)
                      assert_state_variable("total_basic_pay", total_basic_pay)
                    end
                  end
                end
              end

              context "answer 'yes free accommodation' to 'are you provided with accommodation?'" do
                setup do
                  add_response :yes_free
                end
                
                # Q11
                should "ask 'how often do you stay in the accommodation?'" do
                  assert_current_node :accommodation_usage?
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

#  context "paid per hour" do
#    setup do
#      add_response :per_hour
#    end

#    should "ask how old you are" do
#      assert_current_node :how_old_are_you?
#    end

#    context "age provided" do
#      setup do
#        add_response "21_or_over"
#      end

#      should "ask how many hours you work per week" do
#        assert_current_node :how_many_hours_per_week_worked?
#      end

#      should "show minimum wage if hours per week are provided" do
#        add_response "40"
#        assert_current_node :per_hour_minimum_wage
#        assert_state_variable :per_hour_minimum_wage, "6.08"
#        assert_state_variable :hours_per_week, "40"
#        assert_state_variable :per_week_minimum_wage, "243.20"
#      end
#    end
#  end

#  context "paid per piece" do
#    setup do
#      add_response :per_piece
#    end

#    should "ask how old you are" do
#      assert_current_node :how_old_are_you?
#    end

#    context "age provided" do
#      setup do
#        add_response "21_or_over"
#      end

#      should "ask how many pieces you produce per week" do
#        assert_current_node :how_many_pieces_do_you_produce_per_week?
#      end

#      context "number of pieces provided" do
#        setup do
#          add_response "10"
#        end

#        should "ask how much you get paid per piece" do
#          assert_current_node :how_much_do_you_get_paid_per_piece?
#        end

#        context "pay per piece provided" do
#          setup do
#            add_response "30"
#          end

#          should "ask how many hours you work per week" do
#            assert_current_node :how_many_hours_do_you_work_per_week?
#          end

#          should "show minimum wage if pay per piece is provided" do
#            add_response "40"
#            assert_current_node :per_piece_minimum_wage
#            assert_state_variable :hourly_wage, "7.50"
#            assert_state_variable :per_hour_minimum_wage, "6.08"
#            assert_state_variable :above_below, "above"
#          end
#        end
#      end
#    end
#  end
end
