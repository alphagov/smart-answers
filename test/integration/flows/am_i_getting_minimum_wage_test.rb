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
  
  # Current payments
  #
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
              add_response 42
            end
            
            # Q6
            should "ask 'how much do you get paid?'" do
              assert_current_node :how_much_are_you_paid_during_pay_period?
            end
            
            context "answered 158.39 to 'how much do you get paid?'" do
              setup do
                add_response 158.39
              end
              
              # Q7
              should "ask 'how many hours overtime?'" do
                assert_current_node :how_many_hours_overtime_do_you_work?
              end
              
              context "answer '8 hours' to 'how many hours overtime?'" do
                setup do
                  add_response 8
                end
                
                # Q8
                should "ask 'what rate of overtime per hour?'" do
                  assert_current_node :what_is_overtime_pay_per_hour?
                end
                
                context "answer 3.71 to 'overtime per hour?'" do
                  setup do
                    add_response 3.71
                  end
                  # Q9
                  should "ask 'are you provided with accommodation?'" do
                    assert_current_node :is_provided_with_accommodation?
                  end
                  
                  context "answer 'no'" do
                    setup do
                      add_response :no
                    end
                    
                    should "show the results" do
                      assert_current_node :current_payment_below
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
                  
                  should "show the results" do
                    assert_current_node :current_payment_below
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
                      
                      should "show below min. wage results" do
                        assert_current_node :current_payment_below
                      end
                    end
                  end # Accommodation
                end # Overtime rate 
              end # Overtime hours 
            end # Basic pay
            
            # Again with a better basic pay to achieve > min. wage.
            #
            context "answer '300' to 'how much do you get paid?'" do
              setup do
                add_response 300
                add_response 0 # overtime hours
                add_response :no # no accommodation
              end
              should "show above min. wage results" do
                assert_current_node :current_payment_above
              end
            end # Basic pay          
          end # Basic hours
        end # Pay frequency
      end # Age
    end # Apprentice
  end # Current pay

  # Past payments
  #
  context "when checking past pay" do
    setup do
      add_response :past_payment
    end
    
    should "ask 'which year do you want to check?'" do
      assert_current_node :past_payment_year?
    end
    
    context "answer 2009" do
      setup do
        add_response 2009
      end
    
      # Q2
      should "ask 'were you an apprentice?'" do
        assert_current_node :were_you_an_apprentice?
      end
    
      context "answered 'apprentice under 19' to 'are you an apprentice?'" do
        setup do
          add_response :apprentice_over_19
        end
        should "ask 'how often did you get paid?'" do
          assert_current_node :how_often_did_you_get_paid?
        end
      end
    
      context "answered 'apprentice over 19' to 'were you an apprentice?'" do
        setup do
          add_response :apprentice_over_19
        end
        should "ask 'how often did you get paid?'" do
          assert_current_node :how_often_did_you_get_paid?
        end
        
      end
    
      context "answered 'no' to 'were you an apprentice?'" do
        # Q3
        
        setup do
          add_response :no
        end
      
        should "ask 'how old were you?'" do
          assert_current_node :how_old_were_you?
        end
      
        context "answered 19 to 'how old were you?'" do
          setup do
            add_response 19
          end
        
          # Q4
          should "ask 'how often did you get paid?'" do
            assert_current_node :how_often_did_you_get_paid?
          end
        
          context "answered weekly to 'how often did you get paid?'" do
            setup do
              add_response "7"
            end
          
            # Q5
            should "ask 'how many hours did you work?'" do
              assert_current_node :how_many_hours_did_you_work?
            end
            
            context "answered 'how many hours did you work?'" do
              setup do
                add_response 42
              end
            
              # Q6
              should "ask 'how much did you get paid?'" do
                assert_current_node :how_much_were_you_paid_during_pay_period?
              end
            
              context "answered 158.39 to 'how much did you get paid?'" do
                setup do
                  add_response 158.39
                end
              
                # Q7
                should "ask 'how many hours overtime?'" do
                  assert_current_node :how_many_hours_overtime_did_you_work?
                end
              
                context "answer '8 hours' to 'how many hours overtime?'" do
                  setup do
                    add_response 8
                  end
                  
                  # Q8
                  should "ask 'what rate of overtime per hour?'" do
                    assert_current_node :what_was_overtime_pay_per_hour?
                  end
                
                  context "answer 3.71 to 'overtime per hour?'" do
                    # Q9
                    should "ask 'were you provided with accommodation?'" do
                      add_response 3.71
                      assert_current_node :was_provided_with_accommodation?
                    end
                  end              
                end
              
                context "answer 'no overtime' to 'how many hours overtime?'" do
                  setup do
                    add_response 0
                  end
                  
                  # Q9
                  should "ask 'were you provided with accommodation?'" do
                    assert_current_node :was_provided_with_accommodation?
                  end
                
                  context "answer 'no' to 'were you provided with accommodation?'" do
                    setup do
                      add_response :no
                    end
                    
                    should "show the results" do
                      assert_current_node :past_payment_above
                    end
                  end
                
                  # Where accommodation is charged under the £4.73 threshold.
                  # No adjustment is made to basic pay.
                  #
                  context "answer 'yes charged accommodation' to 'were you provided with accommodation?'" do
                    setup do
                      add_response :yes_charged
                    end
                    
                    # Q10
                    should "ask 'how much did you pay for the accommodation?'" do
                      assert_current_node :past_accommodation_charge?
                    end
                    
                    context "answer 4.72 to 'how much did you pay for accommodation?'" do
                      setup do
                        add_response 4.72
                      end
                      
                      should "ask 'how often did you use the accommodation?'" do
                        assert_current_node :past_accommodation_usage?
                      end
                      
                      context "answer 4 to 'how often did you use the accommodation?'" do
                        setup do
                          add_response 4
                        end
                        
                        should "show results" do
                          assert_current_node :past_payment_above
                        end
                      end
                    end
                  end
                end
              end  
             
              # Again with a better basic pay to achieve < min. wage.
              #
              context "answer '200' to 'how much do you get paid?'" do
                setup do
                  add_response 200
                  add_response 0 # overtime hours
                  add_response :no # no accommodation
                end
                should "show above min. wage results" do
                  assert_current_node :past_payment_above
                end
              end # Basic pay        
            end # Basic hours
          end # Pay frequency
        end # Age
      end # Apprentice
    end # Year in question
  end # Past pay
end
