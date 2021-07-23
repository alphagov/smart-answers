require "test_helper"
require "support/flow_test_helper"

class BusinessCoronavirusSupportFinderFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow BusinessCoronavirusSupportFinderFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: business_based?" do
    setup { testing_node :business_based? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of business_size? for an england response" do
        assert_next_node :business_size?, for_response: "england"
      end

      should "have a next node of business_size? for a scotland response" do
        assert_next_node :business_size?, for_response: "scotland"
      end

      should "have a next node of business_size? for a wales response" do
        assert_next_node :business_size?, for_response: "wales"
      end

      should "have a next node of business_size? for a northern_ireland response" do
        assert_next_node :business_size?, for_response: "northern_ireland"
      end
    end
  end

  context "question: business_size?" do
    setup do
      testing_node :business_size?
      add_responses business_based?: "england"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of paye_scheme? for an 0_to_249 response" do
        assert_next_node :paye_scheme?, for_response: "0_to_249"
      end

      should "have a next node of paye_scheme? for an over_249 response" do
        assert_next_node :paye_scheme?, for_response: "over_249"
      end
    end
  end

  context "question: paye_scheme?" do
    setup do
      testing_node :paye_scheme?
      add_responses business_based?: "england",
                    business_size?: "0_to_249"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of self_employed? for a yes response" do
        assert_next_node :self_employed?, for_response: "yes"
      end

      should "have a next node of self_employed? for a no response" do
        assert_next_node :self_employed?, for_response: "no"
      end
    end
  end

  context "question: self_employed?" do
    setup do
      testing_node :self_employed?
      add_responses business_based?: "england",
                    business_size?: "0_to_249",
                    paye_scheme?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of non_domestic_property? for a yes response" do
        assert_next_node :non_domestic_property?, for_response: "yes"
      end

      should "have a next node of non_domestic_property? for a no response" do
        assert_next_node :non_domestic_property?, for_response: "no"
      end
    end
  end

  context "question: non_domestic_property?" do
    setup do
      testing_node :non_domestic_property?
      add_responses business_based?: "england",
                    business_size?: "0_to_249",
                    paye_scheme?: "yes",
                    self_employed?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of sectors? for a yes response" do
        assert_next_node :sectors?, for_response: "yes"
      end

      should "have a next node of sectors? for a no response" do
        assert_next_node :sectors?, for_response: "no"
      end

      should "have a next node of sectors? for a not_sure response" do
        assert_next_node :sectors?, for_response: "not_sure"
      end
    end
  end

  context "question: sectors?" do
    setup do
      testing_node :sectors?
      add_responses business_based?: "england",
                    business_size?: "0_to_249",
                    paye_scheme?: "yes",
                    self_employed?: "yes",
                    non_domestic_property?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of closed_by_restrictions? for a nurseries response" do
        assert_next_node :closed_by_restrictions?, for_response: %w[nurseries]
      end

      should "have a next node of closed_by_restrictions? for a retail_hospitality_or_leisure response" do
        assert_next_node :closed_by_restrictions?, for_response: %w[retail_hospitality_or_leisure]
      end

      should "have a next node of closed_by_restrictions? for a nightclubs_or_adult_entertainment response" do
        assert_next_node :closed_by_restrictions?, for_response: %w[nightclubs_or_adult_entertainment]
      end

      should "have a next node of closed_by_restrictions? for a personal_care response" do
        assert_next_node :closed_by_restrictions?, for_response: %w[personal_care]
      end

      should "have a next node of closed_by_restrictions? for a none response" do
        assert_next_node :closed_by_restrictions?, for_response: %w[none]
      end

      should "have a next node of closed_by_restrictions? for a multiple responses" do
        assert_next_node :closed_by_restrictions?, for_response: %w[nightclubs_or_adult_entertainment personal_care]
      end
    end
  end

  context "question: sectors?" do
    setup do
      testing_node :closed_by_restrictions?
      add_responses business_based?: "england",
                    business_size?: "0_to_249",
                    paye_scheme?: "yes",
                    self_employed?: "yes",
                    non_domestic_property?: "yes",
                    sectors?: %w[none]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results for a local_1 response" do
        assert_next_node :results, for_response: %w[local_1]
      end

      should "have a next node of results for a local_2 response" do
        assert_next_node :results, for_response: %w[local_2]
      end

      should "have a next node of results for a national response" do
        assert_next_node :results, for_response: %w[national]
      end

      should "have a next node of results for a none response" do
        assert_next_node :results, for_response: %w[none]
      end

      should "have a next node of results for a multiple responses" do
        assert_next_node :results, for_response: %w[local_1 national]
      end
    end
  end

  context "outcome: results" do
    setup do
      testing_node :results
      add_responses business_based?: "england",
                    business_size?: "0_to_249",
                    paye_scheme?: "yes",
                    self_employed?: "yes",
                    non_domestic_property?: "yes",
                    sectors?: %w[none],
                    closed_by_restrictions?: %w[none]
    end

    should "render job_retention_scheme if paye_scheme? is yes" do
      assert_rendered_outcome text: "Coronavirus Job Retention Scheme (furlough scheme)"
    end

    should "render statutory_sick_rebate if paye_scheme? is yes and business_size is 0_to_249" do
      assert_rendered_outcome text: "Statutory Sick Pay rebate"
    end

    should "render self_employed_income_scheme if self_employed is yes" do
      assert_rendered_outcome text: "Self-Employment Income Support Scheme (SEISS)"
    end

    should "render kickstart_scheme if business_based is not northern_ireland" do
      assert_rendered_outcome text: "Support to create job placements: Kickstart Scheme"
    end

    should "render vat_reduction if sectors include retail_hospitality_or_leisure" do
      add_responses sectors?: %w[retail_hospitality_or_leisure]

      assert_rendered_outcome text: "VAT reduction for hospitality, accommodation and attractions"
    end

    should "render traineeships if business_based is england" do
      add_responses sectors?: %w[retail_hospitality_or_leisure]

      assert_rendered_outcome text: "Traineeships"
    end

    should "render apprenticeships if business_based is england" do
      add_responses sectors?: %w[retail_hospitality_or_leisure]

      assert_rendered_outcome text: "Apprenticeships"
    end

    should "render tlevels if business_based is england" do
      add_responses sectors?: %w[retail_hospitality_or_leisure]

      assert_rendered_outcome text: "T Levels"
    end

    should "render council_grants if sector retail_hospitality_or_leisure" do
      add_responses sectors?: %w[retail_hospitality_or_leisure]

      assert_rendered_outcome text: "Additional schemes and grants from your local council"
    end

    should "render additional_restrictions_grant if business_based is england" do
      add_responses sectors?: %w[retail_hospitality_or_leisure]

      assert_rendered_outcome text: "Additional Restrictions Grant"
    end

    should "render retail_hospitality_leisure_business_rates if business_based is england, non_domestic_property is yes and sectors include retail_hospitality_or_leisure" do
      add_responses sectors?: %w[retail_hospitality_or_leisure]

      assert_rendered_outcome text: "Business rates holiday for retail, hospitality and leisure"
    end

    should "render nursery_support if business_based is england, non_domestic_property is yes and sectors include nurseries" do
      add_responses sectors?: %w[nurseries]

      assert_rendered_outcome text: "Support for nursery businesses that pay business rates"
    end

    should "render Scottish guidance if business_based is scotland" do
      add_responses business_based?: "scotland"

      assert_rendered_outcome text: "You can be eligible for both Scottish and UK-wide schemes."
    end

    should "render Welsh guidance if business_based is wales" do
      add_responses business_based?: "wales"

      assert_rendered_outcome text: "You can be eligible for both Welsh and UK-wide schemes."
    end

    should "render Northern Ireland guidance if business_based is northern_ireland" do
      add_responses business_based?: "northern_ireland"

      assert_rendered_outcome text: "You can be eligible for both Northern Ireland and UK-wide schemes."
    end
  end
end
