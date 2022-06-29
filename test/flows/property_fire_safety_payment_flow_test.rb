require "test_helper"
require "support/flow_test_helper"

class PropertyFireSafetyPaymentFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow PropertyFireSafetyPaymentFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: building_over_11_metres?" do
    setup { testing_node :building_over_11_metres? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of own_freehold? if yes" do
        assert_next_node :own_freehold?, for_response: "yes"
      end

      should "have an outcome of unlikely_to_need_fixing if no" do
        assert_next_node :unlikely_to_need_fixing, for_response: "no"
      end
    end
  end

  context "question: own_freehold?" do
    setup do
      testing_node :own_freehold?
      add_responses building_over_11_metres?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of own_more_than_3_properties? if no" do
        assert_next_node :own_more_than_3_properties?, for_response: "no"
      end

      should "have an outcome of have_to_pay if yes" do
        assert_next_node :have_to_pay, for_response: "yes"
      end
    end
  end

  context "question: own_more_than_3_properties?" do
    setup do
      testing_node :own_more_than_3_properties?
      add_responses building_over_11_metres?: "yes",
                    own_freehold?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of main_home_february_2022? if yes" do
        assert_next_node :main_home_february_2022?, for_response: "yes"
      end

      should "have a next node of year_of_purchase? if no" do
        assert_next_node :year_of_purchase?, for_response: "no"
      end
    end
  end

  context "question: main_home_february_2022?" do
    setup do
      testing_node :main_home_february_2022?
      add_responses building_over_11_metres?: "yes",
                    own_freehold?: "no",
                    own_more_than_3_properties?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of year_of_purchase? if yes" do
        assert_next_node :year_of_purchase?, for_response: "yes"
      end

      should "have an outcome of have_to_pay if no" do
        assert_next_node :have_to_pay, for_response: "no"
      end
    end
  end

  context "question: year_of_purchase?" do
    setup do
      testing_node :year_of_purchase?
      add_responses building_over_11_metres?: "yes",
                    own_freehold?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of value_of_property if year between 1945 and 2022 given" do
        assert_next_node :value_of_property?, for_response: "2019"
      end

      should "have an invalid response if year outside 1945 - 2022 given" do
        assert_invalid_response("2023")
      end
    end
  end

  context "question: value_of_propety?" do
    setup do
      testing_node :value_of_property?
      add_responses building_over_11_metres?: "yes",
                    own_freehold?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes",
                    year_of_purchase?: "2019"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of live_in_london" do
        assert_next_node :live_in_london?, for_response: "100,000"
      end
    end
  end

  context "outcomes" do
    context "when building is under 11 metres" do
      setup do
        testing_node :unlikely_to_need_fixing
        add_responses building_over_11_metres?: "no"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "Your building is unlikely to need fixing"
      end
    end

    context "when building is over 11 metres and user owns freehold" do
      setup do
        testing_node :have_to_pay
        add_responses building_over_11_metres?: "yes",
                      own_freehold?: "yes"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "You have to pay"
      end
    end

    context "when building is over 11 metres, user doesn't own freehold, user has over 3 propeties and wasn't main home in Feb 2022" do
      setup do
        testing_node :have_to_pay
        add_responses building_over_11_metres?: "yes",
                      own_freehold?: "yes",
                      own_more_than_3_properties?: "yes",
                      main_home_february_2022?: "no"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "You have to pay"
      end
    end
  end
end
