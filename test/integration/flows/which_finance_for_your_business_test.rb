require_relative "../../test_helper"
require_relative "flow_test_helper"

class WhichFinanceForYourBusinessTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "which-finance-is-right-for-your-business"
  end

  should "ask whether willing to offer personal assets" do
    assert_current_node :willing_to_offer_personal_assets?
  end

  context "yes to assets" do
    setup { add_response :yes }

    should "have saved answer and ask whether own business property" do
      assert_state_variable "personal_assets", true
      assert_current_node :own_business_property?
    end
  end

  context "no to assets" do
    setup { add_response :no }

    should "have saved answer and ask whether own business property" do
      assert_state_variable "personal_assets", false
      assert_current_node :own_business_property?
    end

    context "yes to property" do
      setup { add_response :yes }

      should "have saved answer and ask whether willing to give up shares" do
        assert_state_variable "business_property", true
        assert_current_node :give_up_shares?
      end
    end

    context "no to property" do
      setup { add_response :no }

      should "have saved answer and ask whether willing to give up shares" do
        assert_state_variable "business_property", false
        assert_current_node :give_up_shares?
      end

      context "yes to shares" do
        setup { add_response :yes }

        should "have saved answer and ask for minimum amount of funding required" do
          assert_state_variable "shares", true
          assert_current_node :min_amount_funding?
        end
      end

      context "no to shares" do
        setup { add_response :no }
        
        should "have saved answer and ask for minimum amount of funding required" do
          assert_state_variable "shares", false 
          assert_current_node :min_amount_funding?
        end

        should "error if zero" do
          add_response 0
          assert_current_node_is_error
        end

        context "answer 5000 to min funding" do
          setup { add_response 5000 }

          should "ask about max funding" do
            assert_state_variable "min_funding", 5000
            assert_current_node :max_amount_funding?
          end

          should "error if less than min funding" do
            add_response 1000
            assert_current_node_is_error
          end

          context "answer 40000 to max funding" do
            setup { add_response 40000 }

            should "ask about revenue" do
              assert_state_variable "max_funding", 40000
              assert_current_node :last_year_revenue?
            end

            context "answer 250000 to revenue" do
              setup { add_response 250000 }

              should "ask about employees in business" do
                assert_state_variable "revenue", 250000
                assert_current_node :how_many_people_are_in_your_business?
              end

              context "answer under 250" do
                setup { add_response :under_two_hundred_fifty }

                should "calculate inclusions and display result" do
                  assert_state_variable "people", 1
                  assert_current_node :done
                end
              end

              context "answer 250 or over" do
                setup { add_response :two_hundred_fifty_or_over }

                should "calculate inclusions and display result" do
                  assert_state_variable "people", 250
                  assert_current_node :done
                end
              end
            end
          end
        end

      end
    end
  end
end