require "test_helper"
require "support/flow_test_helper"

class CheckFireSafetyCostsFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CheckFireSafetyCostsFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: developer_agreed_to_pay?" do
    setup { testing_node :developer_agreed_to_pay? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have an outcome of developers_pay? if yes" do
        assert_next_node :developers_pay, for_response: "yes"
      end

      should "have an outcome of building_over_11_metres if no" do
        assert_next_node :building_over_11_metres?, for_response: "no"
      end
    end
  end

  context "question: building_over_11_metres?" do
    setup do
      testing_node :building_over_11_metres?
      add_responses developer_agreed_to_pay?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of owned_by_leaseholders? if yes" do
        assert_next_node :owned_by_leaseholders?, for_response: "yes"
      end

      should "have an outcome of unlikely_to_need_to_pay if no" do
        assert_next_node :unlikely_to_need_to_pay, for_response: "no"
      end
    end
  end

  context "question: owned_by_leaseholders?" do
    setup do
      testing_node :owned_by_leaseholders?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of own_more_than_3_properties? if no" do
        assert_next_node :own_more_than_3_properties?, for_response: "no"
      end

      should "have an outcome of have_to_pay_owned_by_leaseholders if yes" do
        assert_next_node :have_to_pay_owned_by_leaseholders, for_response: "yes"
      end
    end
  end

  context "question: own_more_than_3_properties?" do
    setup do
      testing_node :own_more_than_3_properties?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of main_home_february_2022? if yes" do
        assert_next_node :main_home_february_2022?, for_response: "yes"
      end

      should "have a next node of purchased_pre_or_post_february_2022? if no" do
        assert_next_node :purchased_pre_or_post_february_2022?, for_response: "no"
      end
    end
  end

  context "question: main_home_february_2022?" do
    setup do
      testing_node :main_home_february_2022?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no",
                    own_more_than_3_properties?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of purchased_pre_or_post_february_2022? if yes" do
        assert_next_node :purchased_pre_or_post_february_2022?, for_response: "yes"
      end

      should "have an outcome of have_to_pay_not_main_home if no" do
        assert_next_node :have_to_pay_not_main_home, for_response: "no"
      end
    end
  end

  context "question: purchased_pre_or_post_february_2022?" do
    setup do
      testing_node :purchased_pre_or_post_february_2022?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of year_of_purchase?" do
        assert_next_node :year_of_purchase?, for_response: "post_feb_2022"
      end
    end
  end

  context "question: year_of_purchase?" do
    setup do
      testing_node :year_of_purchase?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes",
                    purchased_pre_or_post_february_2022?: "pre_feb_2022"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of value_of_property if year between 1900 and 2022 given" do
        assert_next_node :value_of_property?, for_response: "2019"
      end

      should "have an invalid response if year before 1900 given" do
        assert_invalid_response("1899")
      end

      should "have an invalid response if year after 2022 given" do
        assert_invalid_response("2023")
      end
    end
  end

  context "question: value_of_propety?" do
    setup do
      testing_node :value_of_property?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes",
                    purchased_pre_or_post_february_2022?: "pre_feb_2022",
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

  context "question: live_in_london?" do
    setup do
      testing_node :live_in_london?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes",
                    purchased_pre_or_post_february_2022?: "pre_feb_2022",
                    year_of_purchase?: "2019",
                    value_of_property?: "100000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of shared_ownership" do
        assert_next_node :shared_ownership?, for_response: "yes"
      end
    end
  end

  context "question: shared_ownership?" do
    setup do
      testing_node :shared_ownership?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes",
                    purchased_pre_or_post_february_2022?: "pre_feb_2022",
                    year_of_purchase?: "2019",
                    value_of_property?: "100000",
                    live_in_london?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of percentage_owned if yes" do
        assert_next_node :percentage_owned?, for_response: "yes"
      end

      should "have next node of amoount_already_paid if no" do
        assert_next_node :amount_already_paid?, for_response: "no"
      end
    end
  end

  context "question: percentage_owned?" do
    setup do
      testing_node :percentage_owned?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes",
                    purchased_pre_or_post_february_2022?: "pre_feb_2022",
                    year_of_purchase?: "2019",
                    value_of_property?: "100000",
                    live_in_london?: "yes",
                    shared_ownership?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have next node of amount_already_paid" do
        assert_next_node :amount_already_paid?, for_response: "50.4"
      end

      should "have an invalid response if percentage is over 100" do
        assert_invalid_response("101")
      end

      should "have an invalid response if percentage is under 10" do
        assert_invalid_response("9")
      end
    end
  end

  context "question: amount_already_paid?" do
    setup do
      testing_node :amount_already_paid?
      add_responses developer_agreed_to_pay?: "no",
                    building_over_11_metres?: "yes",
                    owned_by_leaseholders?: "no",
                    own_more_than_3_properties?: "yes",
                    main_home_february_2022?: "yes",
                    purchased_pre_or_post_february_2022?: "pre_feb_2022",
                    year_of_purchase?: "2019",
                    value_of_property?: "100000",
                    live_in_london?: "yes",
                    shared_ownership?: "yes",
                    percentage_owned?: "20"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have an outcome of payment_amount" do
        assert_next_node :payment_amount, for_response: "2000"
      end
    end
  end

  context "outcomes" do
    context "when developers have agreed to pay" do
      setup do
        testing_node :developers_pay
        add_responses developer_agreed_to_pay?: "yes"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "Your developer will pay"
      end
    end

    context "when building is under 11 metres" do
      setup do
        testing_node :unlikely_to_need_to_pay
        add_responses developer_agreed_to_pay?: "no",
                      building_over_11_metres?: "no"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "You're unlikely to need to pay for major fire safety work"
      end
    end

    context "when building is over 11 metres and user owns freehold" do
      setup do
        testing_node :have_to_pay_owned_by_leaseholders
        add_responses developer_agreed_to_pay?: "no",
                      building_over_11_metres?: "yes",
                      owned_by_leaseholders?: "yes"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "You might have to pay to fix fire safety problems or replace cladding."
      end
    end

    context "when building is over 11 metres, user doesn't own freehold, user has over 3 propeties and wasn't main home in Feb 2022" do
      setup do
        testing_node :have_to_pay_not_main_home
        add_responses developer_agreed_to_pay?: "no",
                      building_over_11_metres?: "yes",
                      owned_by_leaseholders?: "no",
                      own_more_than_3_properties?: "yes",
                      main_home_february_2022?: "no"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "You might have to pay to fix fire safety problems or replace cladding."
      end
    end

    context "when a user has a level of ownership and valuation that protects them from costs" do
      setup do
        testing_node :payment_amount
        add_responses developer_agreed_to_pay?: "no",
                      building_over_11_metres?: "yes",
                      owned_by_leaseholders?: "no",
                      own_more_than_3_properties?: "no",
                      main_home_february_2022?: "yes",
                      purchased_pre_or_post_february_2022?: "pre_feb_2022",
                      year_of_purchase?: "2019",
                      value_of_property?: "100000",
                      live_in_london?: "yes",
                      shared_ownership?: "yes",
                      percentage_owned?: "15",
                      amount_already_paid?: "100"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "You do not have to pay to fix fire safety problems or replace cladding."
      end
    end

    context "when a user has a level of ownership and valuation that means they have to pay costs" do
      setup do
        testing_node :payment_amount
        add_responses developer_agreed_to_pay?: "no",
                      building_over_11_metres?: "yes",
                      owned_by_leaseholders?: "no",
                      own_more_than_3_properties?: "no",
                      main_home_february_2022?: "yes",
                      purchased_pre_or_post_february_2022?: "pre_feb_2022",
                      year_of_purchase?: "2019",
                      value_of_property?: "2000000",
                      live_in_london?: "yes",
                      shared_ownership?: "no",
                      amount_already_paid?: "100"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "You might have to pay up to £100,000"
        assert_rendered_outcome text: "The freeholder or ‘landlord’ (whoever is responsible for fixing problems with the building) can only charge you up to £10,000 of this total in a year."
      end
    end
  end
end
