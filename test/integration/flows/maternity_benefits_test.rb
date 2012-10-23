# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class MaternityBenefitsTest < ActiveSupport::TestCase
  include FlowTestHelper

  def week_containing(date_or_string)
    date = Date.parse(date_or_string.to_s)
    start_of_week = date - date.wday
    start_of_week..(start_of_week + 6.days)
  end

  def expected_week_of_childbirth
    raise "@due_date undefined - can't calculate expected_week_of_childbirth without it" unless @due_date
    week_containing(@due_date)
  end

  def qualifying_week
    start = expected_week_of_childbirth.first - 15.weeks
    start .. (start + 6.days)
  end

  def maternity_allowance_test_period
    start = expected_week_of_childbirth.first - 66.weeks
    finish = expected_week_of_childbirth.first - 1.day
    start .. finish
  end

  setup do
    setup_for_testing_flow 'maternity-benefits'
  end

  should "ask when your baby is due" do
    assert_current_node :when_is_your_baby_due?
  end

  context "qualifying week is not this week" do
    setup do
      @due_date = Date.today + 16.weeks
      add_response @due_date
    end

    should "ask if you're employed" do
      assert_current_node :are_you_employed?
    end

    context "employed" do
      setup do
        add_response "yes"
      end
  
      should "ask if you started 26 weeks before qualifying week" do
        assert_current_node :did_you_start_26_weeks_before_qualifying_week?
        assert_state_variable :twenty_six_weeks_before_qualifying_week, qualifying_week.last - 25.weeks
      end
  
      context "started 26 weeks before qualifying week" do
        setup do
          add_response "yes"
        end

        should "ask if you will still be employed in qualifying week" do
          assert_current_node :will_you_still_be_employed_in_qualifying_week?
          assert_state_variable :start_of_qualifying_week, qualifying_week.first
        end

        context "will still be employed in qualifying week" do
          setup do
            add_response "yes"
          end

          should "ask how much you are paid" do
            assert_current_node :how_much_are_you_paid?
          end
  
          context "weekly salary >= 107 and < 1353.5/9" do
            setup do
              add_response "110"
            end
  
            should "tell you you qualify for statutory maternity pay below threshold" do
              assert_current_node :you_qualify_for_statutory_maternity_pay_below_threshold
              assert_state_variable :eligible_amount,  99
            end
          end
  
          context "weekly salary >= 1353.5/9" do
            setup do
              add_response "160"
            end
  
            should "tell you you qualify for statutory maternity pay above threshold" do
              assert_current_node :you_qualify_for_statutory_maternity_pay_above_threshold
              assert_state_variable :eligible_amount, 144
            end
          end
  
          context "weekly salary >= 30 and < 107" do
            setup do
              add_response "50"
            end
  
            should "tell you you qualify for maternity allowance below threshold" do
              assert_current_node :you_qualify_for_maternity_allowance_below_threshold
              assert_state_variable :eligible_amount, 45
            end
          end
  
          context "weekly salary < 30" do
            setup do
              add_response "10"
            end
  
            should "tell you you qualify for nothing, but maybe benefits" do
              assert_current_node :nothing_maybe_benefits
            end
          end
        end # context - will still be employed in qualifying wek

        context "will not still be employed in qualifying week" do
          setup do
            add_response "no"
          end

          should "ask if you will work at least 26 weeks during test period" do
            assert_current_node :will_you_work_at_least_26_weeks_during_test_period?
            assert_state_variable :start_of_test_period, maternity_allowance_test_period.first
            assert_state_variable :end_of_test_period, maternity_allowance_test_period.last
          end

          context "will work at least 26 weeks before during test period" do
            setup do
              add_response "yes"
            end
    
            should "ask how much you earn" do
              assert_current_node :how_much_do_you_earn?
            end
    
            context "weekly salary >=30 and < 1353.5/9" do
              setup do
                add_response "100"
              end
    
              should "tell you you qualify for maternity allowance below threshold" do
                assert_current_node :you_qualify_for_maternity_allowance_below_threshold
                assert_state_variable :eligible_amount, 90
              end
            end
    
            context "weekly salary >= 1353.5/9" do
              setup do
                add_response "160"
              end
    
              should "tell you you qualify for maternity allowance above threshold" do
                assert_current_node :you_qualify_for_maternity_allowance_above_threshold
                assert_state_variable :eligible_amount, 144
              end
            end
    
            context "weekly salary <30" do
              setup do
                add_response "25"
              end
              
              should "tell you you qualify for nothing, but maybe benefits" do
                assert_current_node :nothing_maybe_benefits
              end
            end
          end # context - work at least 26 weeks
    
          context "will not work at least 26 weeks during the test period" do
            setup do
              add_response "no"
            end
    
            should "tell you you qualify for nothing, but maybe benefits" do
              assert_current_node :nothing_maybe_benefits
            end
          end # context - work less 26 weeks
        end # context - will not still be employed in qualifying week
      end # context - started 26 weeks before qualifying week
  
      context "didn't start 26 weeks before qualifying week" do
        setup do
          add_response "no"
        end
  
        should "ask if you will work at least 26 weeks during test period" do
          assert_current_node :will_you_work_at_least_26_weeks_during_test_period?
          assert_state_variable :start_of_test_period, maternity_allowance_test_period.first
          assert_state_variable :end_of_test_period, maternity_allowance_test_period.last
        end
  
        context "will work at least 26 weeks before during test period" do
          setup do
            add_response "yes"
          end
  
          should "ask how much you earn" do
            assert_current_node :how_much_do_you_earn?
          end
  
          context "weekly salary >=30 and < 1353.5/9" do
            setup do
              add_response "100"
            end
  
            should "tell you you qualify for maternity allowance below threshold" do
              assert_current_node :you_qualify_for_maternity_allowance_below_threshold
              assert_state_variable :eligible_amount, 90
            end
          end
  
          context "weekly salary >= 1353.5/9" do
            setup do
              add_response "160"
            end
  
            should "tell you you qualify for maternity allowance above threshold" do
              assert_current_node :you_qualify_for_maternity_allowance_above_threshold
              assert_state_variable :eligible_amount, 144
            end
          end
  
          context "weekly salary <30" do
            setup do
              add_response "25"
            end
            
            should "tell you you qualify for nothing, but maybe benefits" do
              assert_current_node :nothing_maybe_benefits
            end
          end
        end # context - work at least 26 weeks
  
        context "will not work at least 26 weeks during the test period" do
          setup do
            add_response "no"
          end
  
          should "tell you you qualify for nothing, but maybe benefits" do
            assert_current_node :nothing_maybe_benefits
          end
        end # context - work less 26 weeks
      end # context - ddin't start 26 weeks before qualifying week
    end # context - employed

    context "not employed" do
      setup do
        add_response "no"
      end
  
      should "ask if you will work at least 26 weeks during test period" do
        assert_current_node :will_you_work_at_least_26_weeks_during_test_period?
        assert_state_variable :start_of_test_period, maternity_allowance_test_period.first
        assert_state_variable :end_of_test_period, maternity_allowance_test_period.last
      end
  
      context "will work at least 26 weeks before during test period" do
        setup do
          add_response "yes"
        end
  
        should "ask how much you earn" do
          assert_current_node :how_much_do_you_earn?
        end
  
        context "weekly salary >=30 and < 1353.5/9" do
          setup do
            add_response "100"
          end
  
          should "tell you you qualify for maternity allowance below threshold" do
            assert_current_node :you_qualify_for_maternity_allowance_below_threshold
            assert_state_variable :eligible_amount, 90
          end
        end
  
        context "weekly salary >= 1353.5/9" do
          setup do
            add_response "160"
          end
  
          should "tell you you qualify for maternity allowance above threshold" do
            assert_current_node :you_qualify_for_maternity_allowance_above_threshold
             assert_state_variable :eligible_amount, 144
          end
        end
  
        context "weekly salary <30" do
          setup do
            add_response "25"
          end
          
          should "tell you you qualify for nothing, but maybe benefits" do
            assert_current_node :nothing_maybe_benefits
          end
        end
      end # context - will work at least 26 weeks during test period
  
      context "will not work at least 26 weeks during the test period" do
        setup do
          add_response "no"
        end
  
        should "tell you you qualify for nothing, but maybe benefits" do
          assert_current_node :nothing_maybe_benefits
        end
      end # context - will not work at least 26 weeks during test period
    end # context - not employed
  end # context - qualifying week is not this week
  
  context "qualifying week is this week" do
    setup do
      @due_date = Date.today + 15.weeks
      add_response @due_date
    end

    should "ask if you're employed" do
      assert_current_node :are_you_employed?
    end

    context "employed" do
      setup do
        add_response "yes"
      end
  
      should "ask if you started 26 weeks before qualifying week" do
        assert_current_node :did_you_start_26_weeks_before_qualifying_week?
        assert_state_variable :twenty_six_weeks_before_qualifying_week, qualifying_week.last - 25.weeks
      end
  
      context "started 26 weeks before qualifying week" do
        setup do
          add_response "yes"
        end
  
        should "ask how much you are paid" do
          assert_current_node :how_much_are_you_paid?
        end

        context "weekly salary >= 107 and < 1353.5/9" do
          setup do
            add_response "110"
          end

          should "tell you you qualify for statutory maternity pay below threshold" do
            assert_current_node :you_qualify_for_statutory_maternity_pay_below_threshold
            assert_state_variable :eligible_amount,  99
          end
        end

        context "weekly salary >= 1353.5/9" do
          setup do
            add_response "160"
          end

          should "tell you you qualify for statutory maternity pay above threshold" do
            assert_current_node :you_qualify_for_statutory_maternity_pay_above_threshold
            assert_state_variable :eligible_amount, 144
          end
        end

        context "weekly salary >= 30 and < 107" do
          setup do
            add_response "50"
          end

          should "tell you you qualify for maternity allowance below threshold" do
            assert_current_node :you_qualify_for_maternity_allowance_below_threshold
            assert_state_variable :eligible_amount, 45
          end
        end

        context "weekly salary < 30" do
          setup do
            add_response "10"
          end

          should "tell you you qualify for nothing, but maybe benefits" do
            assert_current_node :nothing_maybe_benefits
          end
        end
      end # context - started 26 weeks before qualifying week
  
      context "didn't start 26 weeks before qualifying week" do
        setup do
          add_response "no"
        end
  
        should "ask if you will work at least 26 weeks during test period" do
          assert_current_node :will_you_work_at_least_26_weeks_during_test_period?
          assert_state_variable :start_of_test_period, maternity_allowance_test_period.first
          assert_state_variable :end_of_test_period, maternity_allowance_test_period.last
        end
  
        context "will work at least 26 weeks before during test period" do
          setup do
            add_response "yes"
          end
  
          should "ask how much you earn" do
            assert_current_node :how_much_do_you_earn?
          end
  
          context "weekly salary >=30 and < 1353.5/9" do
            setup do
              add_response "100"
            end
  
            should "tell you you qualify for maternity allowance below threshold" do
              assert_current_node :you_qualify_for_maternity_allowance_below_threshold
              assert_state_variable :eligible_amount, 90
            end
          end
  
          context "weekly salary >= 1353.5/9" do
            setup do
              add_response "160"
            end
  
            should "tell you you qualify for maternity allowance above threshold" do
              assert_current_node :you_qualify_for_maternity_allowance_above_threshold
              assert_state_variable :eligible_amount, 144
            end
          end
  
          context "weekly salary <30" do
            setup do
              add_response "25"
            end
            
            should "tell you you qualify for nothing, but maybe benefits" do
              assert_current_node :nothing_maybe_benefits
            end
          end
        end # context - work at least 26 weeks
  
        context "will not work at least 26 weeks during the test period" do
          setup do
            add_response "no"
          end
  
          should "tell you you qualify for nothing, but maybe benefits" do
            assert_current_node :nothing_maybe_benefits
          end
        end # context - work less 26 weeks
      end # context - ddin't start 26 weeks before qualifying week
    end # context - employed

    context "not employed" do
      setup do
        add_response "no"
      end
  
      should "ask if you will work at least 26 weeks during test period" do
        assert_current_node :will_you_work_at_least_26_weeks_during_test_period?
        assert_state_variable :start_of_test_period, maternity_allowance_test_period.first
        assert_state_variable :end_of_test_period, maternity_allowance_test_period.last
      end
  
      context "will work at least 26 weeks before during test period" do
        setup do
          add_response "yes"
        end
  
        should "ask how much you earn" do
          assert_current_node :how_much_do_you_earn?
        end
  
        context "weekly salary >=30 and < 1353.5/9" do
          setup do
            add_response "100"
          end
  
          should "tell you you qualify for maternity allowance below threshold" do
            assert_current_node :you_qualify_for_maternity_allowance_below_threshold
            assert_state_variable :eligible_amount, 90
          end
        end
  
        context "weekly salary >= 1353.5/9" do
          setup do
            add_response "160"
          end
  
          should "tell you you qualify for maternity allowance above threshold" do
            assert_current_node :you_qualify_for_maternity_allowance_above_threshold
             assert_state_variable :eligible_amount, 144
          end
        end
  
        context "weekly salary <30" do
          setup do
            add_response "25"
          end
          
          should "tell you you qualify for nothing, but maybe benefits" do
            assert_current_node :nothing_maybe_benefits
          end
        end
      end # context - will work at least 26 weeks during test period
  
      context "will not work at least 26 weeks during the test period" do
        setup do
          add_response "no"
        end
  
        should "tell you you qualify for nothing, but maybe benefits" do
          assert_current_node :nothing_maybe_benefits
        end
      end # context - will not work at least 26 weeks during test period
    end # context - not employed
  end # context - qualifying week is this week
end
