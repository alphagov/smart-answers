require "test_helper"
require "support/flow_test_helper"
require "support/flows/check_uk_visa_flow_test_helper"
require "active_support/testing/time_helpers"

class CheckUkVisaJordanFlow10SeptemberTo8OctoberTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers
  include FlowTestHelper
  extend CheckUkVisaFlowTestHelper

  setup do
    testing_flow CheckUkVisaFlow

    # stub only the countries used in this test for less of a performance impact
    stub_worldwide_api_has_locations(%w[jordan].uniq)
  end

  context "Outcomes: for a September 10 to October 8 2024 transition period country during transition period" do
    setup do
      travel_to(Time.zone.local(2024, 10, 8))
    end

    context "No 1: outcome_tourism_visa_partner" do
      should "render if arriving in the UK after September 10 and before October 8 2024" do
        testing_node :outcome_tourism_visa_partner
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "tourism",
                      travelling_visiting_partner_family_member?: "yes"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "You’ll usually need a Standard Visitor visa or family permit to re-enter the UK if either of the following apply"
      end
    end

    context "No 2: outcome_standard_visitor_visa" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_standard_visitor_visa
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "tourism",
                      travelling_visiting_partner_family_member?: "no"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "You’ll usually need a Standard Visitor visa to re-enter the UK if either of the following apply"
      end
    end

    context "No 3: outcome_work_m" do
      should "six_months_or_less: render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_work_m
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "work",
                      staying_for_how_long?: "six_months_or_less"

        assert_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
      end
    end

    context "No 4: outcome_study_m" do
      should "six_months_or_less: render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_study_m
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "study",
                      staying_for_how_long?: "six_months_or_less"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "Find out more about visiting the UK to study"
      end
    end

    context "No 5: outcome_transit_to_the_republic_of_ireland" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_transit_to_the_republic_of_ireland
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "transit",
                      travelling_to_cta?: "republic_of_ireland"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "Depending on your circumstances, you may be able to"
      end
    end

    context "No 6: outcome_transit_leaving_airport_direct_airside_transit_visa" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_transit_leaving_airport_direct_airside_transit_visa
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else",
                      passing_through_uk_border_control?: "yes"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "Depending on your circumstances, you may be able to"
      end
    end

    context "No 7: outcome_transit_not_leaving_airport" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_transit_not_leaving_airport
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else",
                      passing_through_uk_border_control?: "no"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "If you arrive in the UK on a flight and leave again before 00:01 on 11 September 2024, you do not need a visa."
      end
    end

    context "No 8: outcome_partner_family_british_citizen_y" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_partner_family_british_citizen_y
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "family",
                      partner_family_british_citizen?: "yes"

        assert_rendered_outcome text: "Depending on your circumstances, you may also be able to"
        assert_rendered_outcome text: "apply for a free family permit"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
      end
    end

    context "No 9: outcome_partner_family_eea_y" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_partner_family_eea_y
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "family",
                      partner_family_british_citizen?: "no",
                      partner_family_eea?: "yes"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
      end
    end

    context "No 10: outcome_partner_family_eea_n" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_partner_family_eea_n
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "family",
                      partner_family_british_citizen?: "no",
                      partner_family_eea?: "no"

        assert_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "You’ll usually need a Standard Visitor visa or permission to stay as a ‘dependant’ of your family member’s visa category instead."
      end
    end

    context "No 11: outcome_marriage_visa_nat_direct_airside_transit_visa" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_marriage_visa_nat_direct_airside_transit_visa
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "marriage"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "You do not need a Marriage Visitor visa to convert your civil partnership into a marriage"
      end
    end

    context "No 12: outcome_school_y" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_school_y
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "school"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "You’ll need to get a Standard Visitor visa or Parent of a Child Student visa instead"
      end
    end

    context "No 13: outcome_medical_y" do
      should "render if arriving in the UK between September 10 to October 8 2024" do
        testing_node :outcome_medical_y
        add_responses what_passport_do_you_have?: "jordan",
                      purpose_of_visit?: "medical"

        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 8 October 2024"
        assert_rendered_outcome text: "The rules on what you’ll need to enter the UK may be different if you’re travelling from Ireland, Jersey, Guernsey or the Isle of Man."
        assert_rendered_outcome text: "If your treatment will last longer than 6 months"
      end
    end
  end
end
