require "test_helper"
require "support/flow_test_helper"

class SimplifiedExpensesCheckerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow SimplifiedExpensesCheckerFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: vehicle_expense?" do
    setup { testing_node :vehicle_expense? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of what_type_of_student_are_you? for any response" do
        assert_next_node :home_or_business_premises_expense?, for_response: "car"
      end
    end
  end

  context "question: home_or_business_premises_expense?" do
    setup do
      testing_node :home_or_business_premises_expense?
      add_responses vehicle_expense?: "no_vehicle"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of you_cant_use_result if respondent has no vehicle and no expenses" do
        assert_next_node :you_cant_use_result, for_response: "no_expense"
      end

      should "have a next node of buying_new_vehicle? for any response, if respondent previously said they had a business vehicle" do
        add_responses vehicle_expense?: "car"
        assert_next_node :buying_new_vehicle?, for_response: "using_home_for_business"
      end

      should "have a next node of hours_work_home? if respondent has no vehicle and selected the using home for business expense" do
        assert_next_node :hours_work_home?, for_response: "using_home_for_business"
      end

      should "have a next node of deduct_from_premises? if respondent has no vehicle and selected the living on business premises expense" do
        assert_next_node :deduct_from_premises?, for_response: "live_on_business_premises"
      end
    end
  end

  context "question: buying new vehicle?" do
    setup do
      testing_node :buying_new_vehicle?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "using_home_for_business"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_expect_to_claim? if respondent picks either yes option" do
        assert_next_node :how_much_expect_to_claim?, for_response: "new"
      end

      should "have a next node of capital_allowances? if respondent picks the no option" do
        assert_next_node :capital_allowances?, for_response: "no"
      end
    end
  end

  context "question: capital_allowances?" do
    setup do
      testing_node :capital_allowances?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of capital_allowance_result if respondent picks the capital allowances option and did not have any previous expenses" do
        assert_next_node :capital_allowance_result, for_response: "capital_allowance"
      end

      should "have a next node of hours_work_home? if respondent picks the capital allowances option and previously selected the using home for business expense" do
        add_responses home_or_business_premises_expense?: "using_home_for_business"

        assert_next_node :hours_work_home?, for_response: "capital_allowance"
      end

      should "have a next node of deduct_from_premises? if respondent picks the capital allowances option and previously selected the living on business premises expense" do
        add_responses home_or_business_premises_expense?: "live_on_business_premises"

        assert_next_node :deduct_from_premises?, for_response: "capital_allowance"
      end

      should "have a next node of you_cant_claim_capital_allowance if respondent picks the simplified_expenses option and did not have any previous expenses" do
        assert_next_node :you_cant_claim_capital_allowance, for_response: "simplified_expenses"
      end

      should "have a next node of hours_work_home? if respondent picks the simplified_expenses option and previously selected the using home for business expense" do
        add_responses home_or_business_premises_expense?: "using_home_for_business"

        assert_next_node :hours_work_home?, for_response: "simplified_expenses"
      end

      should "have a next node of deduct_from_premises? if respondent picks the simplified_expenses option and previously selected the living on business premises expense" do
        add_responses home_or_business_premises_expense?: "live_on_business_premises"

        assert_next_node :deduct_from_premises?, for_response: "simplified_expenses"
      end

      should "have a next node of how_much_expect_to_claim? if respondent picks the no option and previously selected a van or motorcycle as their vehicle" do
        add_responses vehicle_expense?: "van"

        assert_next_node :how_much_expect_to_claim?, for_response: "no"
      end

      should "have a next node of car_status_before_usage? if respondent picks the no option and previously selected a car as their vehicle" do
        assert_next_node :car_status_before_usage?, for_response: "no"
      end
    end
  end

  context "question: car_status_before_usage?" do
    setup do
      testing_node :car_status_before_usage?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_expect_to_claim? for any response" do
        assert_next_node :how_much_expect_to_claim?, for_response: "new"
      end
    end
  end

  context "question: how_much_expect_to_claim?" do
    setup do
      testing_node :how_much_expect_to_claim?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_vehicle_green? if respondent previously picked a car as their vehicle" do
        assert_next_node :is_vehicle_green?, for_response: "5000"
      end

      should "have a next node of price_of_vehicle? if respondent previously picked a van or motorcycle as their vehicle" do
        add_responses vehicle_expense?: "van"

        assert_next_node :price_of_vehicle?, for_response: "5000"
      end
    end
  end

  context "question: is_vehicle_green?" do
    setup do
      testing_node :is_vehicle_green?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "5000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of price_of_vehicle? for any response" do
        assert_next_node :price_of_vehicle?, for_response: "low"
      end
    end
  end

  context "question: price_of_vehicle?" do
    setup do
      testing_node :price_of_vehicle?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "5000",
                    is_vehicle_green?: "low"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of vehicle_business_use_time? for any response" do
        assert_next_node :vehicle_business_use_time?, for_response: "10000"
      end
    end
  end

  context "question: vehicle_business_use_time?" do
    setup do
      testing_node :vehicle_business_use_time?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "5000",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "10000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of drive_business_miles_car_van? if respondent previously picked a car or van as their vehicle" do
        assert_next_node :drive_business_miles_car_van?, for_response: "50"
      end

      should "have a next node of drive_business_miles_motorcycle? if respondent previously picked a motorcycle as their vehicle" do
        add_responses vehicle_expense?: "motorcycle"

        assert_next_node :drive_business_miles_motorcycle?, for_response: "50"
      end
    end
  end

  context "question: drive_business_miles_car_van?" do
    setup do
      testing_node :drive_business_miles_car_van?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "5000",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "10000",
                    vehicle_business_use_time?: "50"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of hours_work_home? if respondent previously selected the using home for business expense" do
        add_responses home_or_business_premises_expense?: "using_home_for_business"

        assert_next_node :hours_work_home?, for_response: "20000"
      end

      should "have a next node of deduct_from_premises? if respondent previously selected the living on business premises expense" do
        add_responses home_or_business_premises_expense?: "live_on_business_premises"

        assert_next_node :deduct_from_premises?, for_response: "20000"
      end

      should "have a next node of you_can_use_result if respondent previously picked no expenses" do
        assert_next_node :you_can_use_result, for_response: "20000"
      end
    end
  end

  context "question: drive_business_miles_motorcycle?" do
    setup do
      testing_node :drive_business_miles_motorcycle?
      add_responses vehicle_expense?: "motorcycle",
                    home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    how_much_expect_to_claim?: "5000",
                    price_of_vehicle?: "10000",
                    vehicle_business_use_time?: "50"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of hours_work_home? if respondent previously selected the using home for business expense" do
        add_responses home_or_business_premises_expense?: "using_home_for_business"

        assert_next_node :hours_work_home?, for_response: "20000"
      end

      should "have a next node of deduct_from_premises? if respondent previously selected the living on business premises expense" do
        add_responses home_or_business_premises_expense?: "live_on_business_premises"

        assert_next_node :deduct_from_premises?, for_response: "20000"
      end

      should "have a next node of you_can_use_result if respondent previously picked no expenses" do
        assert_next_node :you_can_use_result, for_response: "20000"
      end
    end
  end

  context "question: hours_work_home?" do
    setup do
      testing_node :hours_work_home?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "using_home_for_business",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "5000",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "10000",
                    vehicle_business_use_time?: "50",
                    drive_business_miles_car_van?: "20000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "be invalid if the number of hours entered is less than 1" do
        assert_invalid_response "0"
      end

      should "have a next node of you_cant_use_result if respondent gives an response of under 25 hours" do
        assert_next_node :you_cant_use_result, for_response: "20"
      end

      should "have a next node of current_claim_amount_home? if respondent gives an response over 25 hours" do
        assert_next_node :current_claim_amount_home?, for_response: "100"
      end
    end
  end

  context "question: current_claim_amount_home?" do
    setup do
      testing_node :current_claim_amount_home?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "using_home_for_business",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "5000",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "10000",
                    vehicle_business_use_time?: "50",
                    drive_business_miles_car_van?: "20000",
                    hours_work_home?: "100"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of you_can_use_result for any response" do
        assert_next_node :you_can_use_result, for_response: "20"
      end
    end
  end

  context "question: deduct_from_premises?" do
    setup do
      testing_node :deduct_from_premises?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "live_on_business_premises",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "5000",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "10000",
                    vehicle_business_use_time?: "50",
                    drive_business_miles_car_van?: "20000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of people_live_on_premises? for any response" do
        assert_next_node :people_live_on_premises?, for_response: "40000"
      end
    end
  end

  context "question: people_live_on_premises?" do
    setup do
      testing_node :people_live_on_premises?
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "live_on_business_premises",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "5000",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "10000",
                    vehicle_business_use_time?: "50",
                    drive_business_miles_car_van?: "20000",
                    deduct_from_premises?: "40000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of you_can_use_result for any response" do
        assert_next_node :you_can_use_result, for_response: "4"
      end
    end
  end

  context "outcome: you_can_use_result" do
    setup do
      testing_node :you_can_use_result
      add_responses vehicle_expense?: "car",
                    home_or_business_premises_expense?: "using_home_for_business",
                    buying_new_vehicle?: "no",
                    capital_allowances?: "simplified_expenses",
                    hours_work_home?: "100",
                    current_claim_amount_home?: "10"
    end

    should "render text if respondent claimed simplified expenses and did not buy a new/used vehicle" do
      assert_rendered_outcome text: "You can’t claim capital allowances for your vehicle because you’ve already claimed simplified expenses for it."
    end

    should "render text if respondent claimed capital allowance and did not buy a new/used vehicle" do
      add_responses capital_allowances?: "capital_allowance"

      assert_rendered_outcome text: "You can’t use simplified expenses for your vehicle because you’ve already claimed capital allowances for it"
    end

    should "render text if the total of simple costs exceeds that of current scheme costs" do
      assert_rendered_outcome text: "You would probably be better off using simplified expenses"
    end

    should "render text if the total of current scheme costs exceeds that of simple costs" do
      add_responses current_claim_amount_home?: "10000"

      assert_rendered_outcome text: "You would probably be better off working out your expenses based on the actual costs"
    end

    should "not render vehicle cost potential claim text, in the simplified expenses section, if the user has claimed capital expenses" do
      add_responses capital_allowances?: "capital_allowance"

      assert_no_match "for your car or van", @test_flow.outcome_text
    end

    should "not render vehicle cost potential claim text, in the simplified expenses section, if the simple vehicle cost for van/car is 0" do
      add_responses capital_allowances?: "no",
                    car_status_before_usage?: "new",
                    how_much_expect_to_claim?: "10",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "50",
                    vehicle_business_use_time?: "50",
                    drive_business_miles_car_van?: "0",
                    hours_work_home?: "100",
                    current_claim_amount_home?: "1000"

      assert_no_match "for your car or van", @test_flow.outcome_text
    end

    should "render text in the simplified expenses section if the simple vehicle costs for motorcycles is above 0" do
      add_responses vehicle_expense?: "motorcycle",
                    capital_allowances?: "no",
                    how_much_expect_to_claim?: "10",
                    price_of_vehicle?: "50",
                    vehicle_business_use_time?: "50",
                    drive_business_miles_motorcycle?: "10",
                    hours_work_home?: "100",
                    current_claim_amount_home?: "1000"

      assert_rendered_outcome text: "to claim for motorcycles"
    end

    should "render text for working from home, in the simplified expenses section, if the hours worked at home is above 25" do
      assert_rendered_outcome text: "to claim for working from home"
    end

    should "render text for living on business premises, in the simplified expenses section, if the number of people living on the premises is grater than 0" do
      add_responses home_or_business_premises_expense?: "live_on_business_premises",
                    deduct_from_premises?: "40000",
                    people_live_on_premises?: "2"

      assert_rendered_outcome text: "to deduct from your total business costs - you then claim the balance"
    end

    should "render text if the user has claimed running costs for the vehicle" do
      add_responses home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "new",
                    how_much_expect_to_claim?: "50000",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "50",
                    vehicle_business_use_time?: "50",
                    drive_business_miles_car_van?: "1000"

      assert_rendered_outcome text: "for the running costs of your car, van or motorcycle"
    end

    should "render text if the vehicle price exceeds the Capital Allowance write off limit" do
      add_responses home_or_business_premises_expense?: "no_expense",
                    buying_new_vehicle?: "new",
                    how_much_expect_to_claim?: "50000",
                    is_vehicle_green?: "low",
                    price_of_vehicle?: "300,000",
                    vehicle_business_use_time?: "50",
                    drive_business_miles_car_van?: "1000"

      assert_rendered_outcome text: "The upper limit for Capital Allowance write offs for vans is £250,000"
    end
  end
end
