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

    context "A on Q2 and new business on Q1" do
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

            context "answering Q6 - % of private use" do
              setup do
                add_response "100000" # answer Q5
              end

              should "correctly calculate the write off amount" do
                add_response "15"
                assert_state_variable :private_use_percent, 15.0
                # write off = 15% of Q5 answer
                assert_state_variable :green_vehicle_write_off, 15000.0
              end
            end # Q6 % private use of vehicle

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

            context "answering Q6 with dirty vehicle" do
              setup do
                add_response "100000" # answering Q5
              end

              should "calculate variables correctly" do
                add_response "15"
                assert_state_variable :private_use_percent, 15.0
                # write off = 15% of 18% of Q5 answer
                assert_state_variable :dirty_vehicle_write_off, 2700.0
              end

              should "take the user to Q7" do
                add_response "15" # answering Q6
                assert_state_variable :private_use_percent, 15.0
                assert_current_node :drive_business_miles_car_van?
              end

              context "answering Q7" do
                setup do
                  add_response "15" #answer Q6
                end
                should "calculate the amount correctly for value < 10k" do
                  add_response "9000"
                  assert_state_variable :simple_vehicle_costs, 4050.0
                end

                should "calculate the amount correctly for value > 10k" do
                  add_response "10400"
                  assert_state_variable :simple_vehicle_costs, 4596.0
                end
              end #Q7
            end # answering Q6
          end # answering Q5
        end # Q4 answering no (vehicle isn't green)

      end #answering Q4 "dirty"

    end #answering Q2 "car_or_van"
    context "answering Q2 with 'motorcycle,using_home_for_business'" do
      context "answering Q8" do
        setup do
          add_response "car_or_van,motorcycle,using_home_for_business" #Q2
          add_response :yes #Q4
          add_response "100000" #Q5
          add_response "15" #Q6
          add_response "1000" #Q7
        end
        should "calculate the motorcycle cost correctly" do
          add_response "1000" #Q8
          assert_state_variable :simple_motorcycle_costs, 250
        end
      end

    end
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
          assert_current_node :current_claim_amount_home?
        end
      end # answering using_home_for_business on Q2

      context "answering just D for Q2 takes you to Q11" do
        should "take you to Q11" do
          add_response "live_on_business_premises"
          assert_current_node :deduct_from_premises?
        end

        context "Answering Q11" do
          setup do
            add_response "live_on_business_premises"
          end

          should "calculate the cost and take user to Q12" do
            add_response "500"
            assert_state_variable :business_premises_cost, 500.0
            assert_current_node :people_live_on_premises?
          end

          context "Answering Q12" do
            setup do
              add_response "500"
            end

            should "calculate number and take user to result" do
              add_response "5"
              assert_state_variable :live_on_premises, 5
              assert_current_node :you_can_use_result
            end
          end # answering Q12

        end # answering Q11
      end #answering live_on_business_premises for Q2

      context "answering Q3" do
        should "take user to Q7 if they picked car_or_van in Q2" do
          add_response "car_or_van" #Q2
          add_response "100"
          assert_state_variable :vehicle_tax_amount, 100
          assert_current_node :drive_business_miles_car_van?
        end

        should "take user to Q8 if user picked motorcycle but not car_or_van" do
          add_response "motorcycle" #Q2
          add_response "100"
          assert_state_variable :vehicle_tax_amount, 100
          assert_current_node :drive_business_miles_motorcycle?
        end
      end #answering Q3
    end # answering Q2
  end # answering 'existing' to Q1


  # testing Q7 next_node logic
  context "Progressing from Question 7" do
    setup do
      add_response :new #Q1
    end

    should "take the user to Q8 after answering Q7 if Q2 answer includes motorcycle" do
      add_response "car_or_van,motorcycle" #Q2
      add_response :yes #Q4
      add_response "100000" #Q5
      add_response "15" #Q6
      add_response "10000"
      assert_current_node :drive_business_miles_motorcycle?
    end

    should "skip Q7 if the user doesn't own a car or van" do
      add_response "motorcycle" #Q2
      add_response :yes #Q4
      add_response "100000" #Q5
      add_response "15" #Q6
      assert_current_node :drive_business_miles_motorcycle?
    end

    should "skip Q8 if the user doesn't own a motorcycle" do
      add_response "car_or_van" #Q2
      add_response :yes #Q4
      add_response "100000" #Q5
      add_response "15" #Q6
      add_response "1000" #Q7
      assert_current_node :you_can_use_result
    end

    should "go from Q7 to Q9 if the user picked A and C on Q2" do
      add_response "car_or_van,using_home_for_business" #Q2
      add_response :yes #Q4
      add_response "100000" #Q5
      add_response "15" #Q6
      add_response "1000" #Q7
      assert_current_node :current_claim_amount_home?
    end

    should "go from Q8 to Q9 if the user picked A, B and C on Q2" do
      add_response "car_or_van,motorcycle,using_home_for_business" #Q2
      add_response :yes #Q4
      add_response "100000" #Q5
      add_response "15" #Q6
      add_response "1000" #Q7
      add_response "1000" #Q8
      assert_current_node :current_claim_amount_home?
    end

    should "go from Q8 to Q11 if the user picked motorcycle and live_on_business_premises" do
      add_response "car_or_van,motorcycle,live_on_business_premises" #Q2
      add_response :yes #Q4
      add_response "100000" #Q5
      add_response "15" #Q6
      add_response "1000" #Q7
      add_response "1000" #Q8
      assert_current_node :deduct_from_premises?
    end
  end # progressing from Q7

end
