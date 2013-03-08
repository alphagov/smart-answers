require_relative "../../test_helper"
require_relative "flow_test_helper"

class HelpIfYouAreArrestedAbroad < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "hmrc-simplified-expenses-tracker"
  end

  should "ask new or existing business question" do
    assert_current_node :new_or_existing_business?
  end

  context "answering 'new' to Q1" do
    setup do
      add_response :new
    end

    should "store Q1 answer in variable" do
      assert_state_variable :new_or_existing_business, "new"
      assert_state_variable :is_new_business, true
      assert_state_variable :is_existing_business, false
    end

    context "answering Q2" do
      context "selecting just car_van as expense type" do
        setup do
          add_response :car_or_van
        end

        should "calculate list of expenses array" do
          assert_state_variable :list_of_expenses, ["car_or_van"]
        end

        should "take user to Q4" do
          assert_current_node :is_vehicle_green?
        end
      end # car_van only on Q2

      context "selecting car_or_van and motorcycle as expense type" do
        setup do
          add_response "car_or_van,motorcycle"
        end

        should "take the user to Q4" do
          assert_current_node :is_vehicle_green?
        end
      end # car_van or motorcycle on Q2

      context "selecting just motorcycle as expense type" do
        setup do
          add_response "motorcycle"
        end

        should "take the user to Q4" do
          assert_current_node :is_vehicle_green?
        end
      end # just motorcycle on Q2
    end # answering Q2

    context "A/B on Q2 and new business on Q1" do
      setup do
        add_response "car_or_van" # answering Q2
      end

      should "take the user to Q4" do
        assert_current_node :is_vehicle_green?
      end

      context "answering Q4 - is_vehicle_green?" do
        context "answering yes" do
          setup do
            add_response :yes
          end

          should "store answer in variable and move to Q5" do
            assert_state_variable :vehicle_is_green, true
            assert_current_node :price_of_vehicle?
          end

          context "answering Q5 - vehicle price with green vehicle" do
            context "answering less than 250k" do
              setup do
                add_response "100,000"
              end

              should "calculate response as 100000.0" do
                assert_state_variable :vehicle_price, 100000.0
                assert_state_variable :is_over_limit, false
                assert_state_variable :green_vehicle_price, 100000.0
              end
            end # answering < 250k

            context "answer more than 250k" do
              setup do
                add_response "260000"
              end

              should "set is_over_limit if response > 250k" do
                assert_state_variable :vehicle_price, 260000.0
                assert_state_variable :is_over_limit, true
              end
            end # answering > 250k
          end # Q5 vehicle price
        end # Q4 answering yes

        context "answering no" do
          setup do
            add_response :no
          end

          should "store answer in variable and move to Q5" do
            assert_state_variable :vehicle_is_green, false
            assert_current_node :price_of_vehicle?
          end

          context "answering Q5 - vehicle price with dirty vehicle" do
            context "answering less than 250k" do
              setup do
                add_response "100000"
              end

              should "calculate state variables correctly" do
                assert_state_variable :is_over_limit, false
                assert_state_variable :green_vehicle_price, nil
                # dirty vehicle cost = 18% of input
                assert_state_variable :dirty_vehicle_price, 18000.0
              end
            end

            context "answering more than 250k" do
              setup do
                add_response "255,000"
              end
              should "calculate state variables correctly" do
                assert_state_variable :is_over_limit, true
                assert_state_variable :green_vehicle_price, nil
                assert_state_variable :dirty_vehicle_price, 45900.0
              end
            end
          end
        end

      end #answering Q4

    end #answering Q2
  end # answering 'new' on Q1

  context "answering 'existing' to Q1" do
    setup do
      add_response :existing
    end

    should "store Q1 answer in variable" do
      assert_state_variable :new_or_existing_business, "existing"
      assert_state_variable :is_existing_business, true
      assert_state_variable :is_new_business, false
    end

    context "answering Q2" do
      context "selecting just car_van as expense type" do
        setup do
          add_response :car_or_van
        end

        should "calculate list of expenses array" do
          assert_state_variable :list_of_expenses, ["car_or_van"]
        end

        should "take user to Q3" do
          assert_current_node :how_much_write_off_tax?
        end
      end # car_van only on Q2

      context "selecting car_or_van and motorcycle as expense type" do
        setup do
          add_response "car_or_van,motorcycle"
        end

        should "take the user to Q3" do
          assert_current_node :how_much_write_off_tax?
        end
      end # car_van or motorcycle on Q2

      context "selecting just motorcycle as expense type" do
        setup do
          add_response "motorcycle"
        end

        should "take the user to Q3" do
          assert_current_node :how_much_write_off_tax?
        end
      end # just motorcycle on Q2

      context "selecting other options for Q2 should calculate list_of_expenses correctly" do
        context "selecting all options other than the last" do
          setup do
            add_response "car_or_van,motorcycle,using_home_for_business,live_on_business_premises"
          end
          should "store responses in an array" do
            assert_state_variable :list_of_expenses, ["car_or_van", "live_on_business_premises", "motorcycle", "using_home_for_business"]
          end
        end
      end # selecting all but last option Q2

      context "selecting none_of_above on Q2" do
        should "take you to outcome 1" do
          add_response "none_of_these"
          assert_current_node :you_cant_use_result
        end
      end # selecting none_of_these on Q2

      context "answering just C for Q2 takes you to Q9" do
        should "take you through to Q9" do
          add_response "using_home_for_business"
          assert_current_node :current_claim_amount?
        end
      end # answering using_home_for_business on Q2

      context "answering just D for Q2 takes you to Q11" do
        should "take you to Q11" do
          add_response "live_on_business_premises"
          assert_current_node :deduct_from_premises?
        end
      end #answering live_on_business_premises for Q2
    end # answering Q2
  end # answering 'existing' to Q1


end
