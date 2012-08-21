require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatePensionTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-state-pension'
  end

  should "ask your gender" do
    assert_current_node :gender?
  end

  context "male" do
    setup do
      add_response :male
    end
    
    should "ask which calculation to perform" do
      assert_current_node :which_calculation?
    end
    
    context "age calculation" do
      
      setup do
        add_response :age
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
      end
    end
    
    context "amount calculation" do
    
      setup do
        add_response :amount
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

        context "30 years" do
          should "show the result" do
            add_response 30
            assert_current_node :amount_result
          end
        end

        context "27 years" do
          setup do
            add_response 27
          end

          should "ask for number of years claimed JSA" do
            assert_current_node :years_of_jsa?
          end

          context "10 years" do
            should "show the result" do
              add_response 10
              assert_current_node :amount_result
            end
          end

          context "1 year" do
            setup do
              add_response 1
            end

            should "ask for years of benefit" do
              assert_current_node :years_of_benefit?
            end

            context "10 years" do
              should "show the result" do
                add_response 10
                assert_current_node :amount_result
              end
            end

            context "1 year" do
              setup do
                add_response 1
              end

              should "ask for years working" do
                assert_current_node :years_of_work?
              end

              context "1 year" do
                should "show the result" do
                  add_response 1
                  assert_current_node :amount_result
                end
              end
            end
          end
        end
      end
    end
  end
end
