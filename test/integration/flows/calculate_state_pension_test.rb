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

    should "ask for date of birth" do
      assert_current_node :dob?
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
          assert_current_node :result
        end
      end

      context "28 years" do
        setup do
          add_response 28
        end

        should "ask for number of years claimed JSA" do
          assert_current_node :years_of_jsa?
        end

        context "10 years" do
          should "show the result" do
            add_response 10
            assert_current_node :result
          end
        end

        context "1 year" do
          setup do
            add_response 1
          end

          should "ask for years of benifit" do
            assert_current_node :years_of_benifit?
          end

          context "10 years" do
            should "show the result" do
              add_response 10
              assert_current_node :result
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
                assert_current_node :result
              end
            end
          end
        end
      end
    end
  end
end