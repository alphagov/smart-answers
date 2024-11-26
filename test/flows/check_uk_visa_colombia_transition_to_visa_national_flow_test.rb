require "test_helper"
require "support/flow_test_helper"
require "support/flows/check_uk_visa_flow_test_helper"
require "active_support/testing/time_helpers"

class CheckUkVisaColombiaTransitionToVisaNationalFlowTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers
  include FlowTestHelper

  setup do
    testing_flow CheckUkVisaFlow

    # stub only the countries used in these tests for less of a performance impact
    stub_worldwide_api_has_locations(%w[colombia jordan].uniq)
  end

  # The transitional partials will display as soon as the code is merged; hence the start date is not embedded in the
  # code anywhere—it will be handled by merging at the appropriate datetime
  context "when viewing colombian passport outcomes on or before the transition period end date" do
    setup do
      # The transition end date is 24 December 2024
      travel_to(Time.zone.local(2024, 12, 24))
      add_responses what_passport_do_you_have?: "colombia"
    end

    context "No 1: outcome_tourism_visa_partner" do
      should "render transition text" do
        testing_node :outcome_tourism_visa_partner
        add_responses purpose_of_visit?: "tourism",
                      travelling_visiting_partner_family_member?: "yes"

        assert_rendered_outcome text: "You’ll usually need a visa to come to the UK"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 2: outcome_standard_visitor_visa" do
      should "render transition text" do
        testing_node :outcome_standard_visitor_visa
        add_responses purpose_of_visit?: "tourism",
                      travelling_visiting_partner_family_member?: "no"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 3: outcome_work_m" do
      should "render transition text" do
        testing_node :outcome_work_m
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "six_months_or_less"

        assert_rendered_outcome text: "You'll need a visa to work, do business or academic research in the UK"
        assert_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 4: outcome_study_m" do
      should "render transition text" do
        testing_node :outcome_study_m
        add_responses purpose_of_visit?: "study",
                      staying_for_how_long?: "six_months_or_less"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 5: outcome_transit_to_the_republic_of_ireland" do
      should "render transition text" do
        testing_node :outcome_transit_to_the_republic_of_ireland
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "republic_of_ireland"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK (unless you’re exempt)"
        assert_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 6: outcome_transit_leaving_airport_direct_airside_transit_visa" do
      should "render transition text" do
        testing_node :outcome_transit_leaving_airport_direct_airside_transit_visa
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else",
                      passing_through_uk_border_control?: "yes"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK in transit"
        assert_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 7: outcome_transit_not_leaving_airport" do
      should "render transition text" do
        testing_node :outcome_transit_not_leaving_airport
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else",
                      passing_through_uk_border_control?: "no"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK in transit"
        assert_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different"
        assert_rendered_outcome text: "If you’re arriving in the UK before 11.59pm (UK time) on 24 December 2024"
      end
    end

    context "No 8: outcome_partner_family_british_citizen_y" do
      should "render transition text" do
        testing_node :outcome_partner_family_british_citizen_y
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "yes"

        assert_rendered_outcome text: "You’ll need a visa to join your family or partner in the UK"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 9: outcome_partner_family_eea_y" do
      should "render transition text" do
        testing_node :outcome_partner_family_eea_y
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "no",
                      partner_family_eea?: "yes"

        assert_rendered_outcome text: "You may need a visa"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 10: outcome_partner_family_eea_n" do
      should "render transition text" do
        testing_node :outcome_partner_family_eea_n
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "no",
                      partner_family_eea?: "no"

        assert_rendered_outcome text: "You’ll need a visa to join your family or partner in the UK"
        assert_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 11: outcome_marriage_visa_nat_direct_airside_transit_visa" do
      should "render transition text" do
        testing_node :outcome_marriage_visa_nat_direct_airside_transit_visa
        add_responses purpose_of_visit?: "marriage"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_rendered_outcome text: "If you want to convert a civil partnership into a marriage"
      end
    end

    context "No 12: outcome_school_y" do
      should "render transition text" do
        testing_node :outcome_school_y
        add_responses purpose_of_visit?: "school"

        assert_rendered_outcome text: "You’ll need a visa to stay with your child"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 13: outcome_medical_y" do
      should "render transition text" do
        testing_node :outcome_medical_y
        add_responses purpose_of_visit?: "medical"

        assert_rendered_outcome text: "You’ll need a visa to visit the UK"
        assert_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end
  end

  context "when viewing colombian passport outcomes after the transition period end date" do
    setup do
      # The transition end date is 24 December 2024
      travel_to(Time.zone.local(2024, 12, 25))
      add_responses what_passport_do_you_have?: "colombia"
    end

    context "No 1: outcome_tourism_visa_partner" do
      should "not render transition text" do
        testing_node :outcome_tourism_visa_partner
        add_responses purpose_of_visit?: "tourism",
                      travelling_visiting_partner_family_member?: "yes"

        assert_rendered_outcome text: "You’ll usually need a visa to come to the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 2: outcome_standard_visitor_visa" do
      should "not render transition text" do
        testing_node :outcome_standard_visitor_visa
        add_responses purpose_of_visit?: "tourism",
                      travelling_visiting_partner_family_member?: "no"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 3: outcome_work_m" do
      should "not render transition text" do
        testing_node :outcome_work_m
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "six_months_or_less"

        assert_rendered_outcome text: "You'll need a visa to work, do business or academic research in the UK"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 4: outcome_study_m" do
      should "not render transition text" do
        testing_node :outcome_study_m
        add_responses purpose_of_visit?: "study",
                      staying_for_how_long?: "six_months_or_less"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 5: outcome_transit_to_the_republic_of_ireland" do
      should "not render transition text" do
        testing_node :outcome_transit_to_the_republic_of_ireland
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "republic_of_ireland"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK (unless you’re exempt)"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 6: outcome_transit_leaving_airport_direct_airside_transit_visa" do
      should "not render transition text" do
        testing_node :outcome_transit_leaving_airport_direct_airside_transit_visa
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else",
                      passing_through_uk_border_control?: "yes"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK in transit"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 7: outcome_transit_not_leaving_airport" do
      should "not render transition text" do
        testing_node :outcome_transit_not_leaving_airport
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else",
                      passing_through_uk_border_control?: "no"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK in transit"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 11.59pm (UK time) on 24 December 2024"
      end
    end

    context "No 8: outcome_partner_family_british_citizen_y" do
      should "not render transition text" do
        testing_node :outcome_partner_family_british_citizen_y
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "yes"

        assert_rendered_outcome text: "You’ll need a visa to join your family or partner in the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 9: outcome_partner_family_eea_y" do
      should "not render transition text" do
        testing_node :outcome_partner_family_eea_y
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "no",
                      partner_family_eea?: "yes"

        assert_rendered_outcome text: "You may need a visa"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 10: outcome_partner_family_eea_n" do
      should "not render transition text" do
        testing_node :outcome_partner_family_eea_n
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "no",
                      partner_family_eea?: "no"

        assert_rendered_outcome text: "You’ll need a visa to join your family or partner in the UK"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 11: outcome_marriage_visa_nat_direct_airside_transit_visa" do
      should "not render transition text" do
        testing_node :outcome_marriage_visa_nat_direct_airside_transit_visa
        add_responses purpose_of_visit?: "marriage"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_no_rendered_outcome text: "If you want to convert a civil partnership into a marriage"
      end
    end

    context "No 12: outcome_school_y" do
      should "not render transition text" do
        testing_node :outcome_school_y
        add_responses purpose_of_visit?: "school"

        assert_rendered_outcome text: "You’ll need a visa to stay with your child"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 13: outcome_medical_y" do
      should "not render transition text" do
        testing_node :outcome_medical_y
        add_responses purpose_of_visit?: "medical"

        assert_rendered_outcome text: "You’ll need a visa to visit the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end
  end

  context "when viewing non-colombian passport outcomes on or before the transition period end date" do
    setup do
      # The transition end date is 24 December 2024
      travel_to(Time.zone.local(2024, 12, 24))
      add_responses what_passport_do_you_have?: "jordan"
    end

    context "No 1: outcome_tourism_visa_partner" do
      should "not render transition text" do
        testing_node :outcome_tourism_visa_partner
        add_responses purpose_of_visit?: "tourism",
                      travelling_visiting_partner_family_member?: "yes"

        assert_rendered_outcome text: "You’ll usually need a visa to come to the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 2: outcome_standard_visitor_visa" do
      should "not render transition text" do
        testing_node :outcome_standard_visitor_visa
        add_responses purpose_of_visit?: "tourism",
                      travelling_visiting_partner_family_member?: "no"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 3: outcome_work_m" do
      should "not render transition text" do
        testing_node :outcome_work_m
        add_responses purpose_of_visit?: "work",
                      staying_for_how_long?: "six_months_or_less"

        assert_rendered_outcome text: "You'll need a visa to work, do business or academic research in the UK"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 4: outcome_study_m" do
      should "not render transition text" do
        testing_node :outcome_study_m
        add_responses purpose_of_visit?: "study",
                      staying_for_how_long?: "six_months_or_less"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 5: outcome_transit_to_the_republic_of_ireland" do
      should "not render transition text" do
        testing_node :outcome_transit_to_the_republic_of_ireland
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "republic_of_ireland"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK (unless you’re exempt)"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 6: outcome_transit_leaving_airport_direct_airside_transit_visa" do
      should "not render transition text" do
        testing_node :outcome_transit_leaving_airport_direct_airside_transit_visa
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else",
                      passing_through_uk_border_control?: "yes"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK in transit"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 7: outcome_transit_not_leaving_airport" do
      should "not render transition text" do
        testing_node :outcome_transit_not_leaving_airport
        add_responses purpose_of_visit?: "transit",
                      travelling_to_cta?: "somewhere_else",
                      passing_through_uk_border_control?: "no"

        assert_rendered_outcome text: "You’ll need a visa to pass through the UK in transit"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 11.59pm (UK time) on 24 December 2024"
      end
    end

    context "No 8: outcome_partner_family_british_citizen_y" do
      should "not render transition text" do
        testing_node :outcome_partner_family_british_citizen_y
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "yes"

        assert_rendered_outcome text: "You’ll need a visa to join your family or partner in the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 9: outcome_partner_family_eea_y" do
      should "not render transition text" do
        testing_node :outcome_partner_family_eea_y
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "no",
                      partner_family_eea?: "yes"

        assert_rendered_outcome text: "You may need a visa"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 10: outcome_partner_family_eea_n" do
      should "not render transition text" do
        testing_node :outcome_partner_family_eea_n
        add_responses purpose_of_visit?: "family",
                      partner_family_british_citizen?: "no",
                      partner_family_eea?: "no"

        assert_rendered_outcome text: "You’ll need a visa to join your family or partner in the UK"
        assert_no_rendered_outcome text: "The rules on what you’ll need to come to the UK may be different if you're arriving in the UK before 3pm (UK time) on 24 December 2024."
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 11: outcome_marriage_visa_nat_direct_airside_transit_visa" do
      should "not render transition text" do
        testing_node :outcome_marriage_visa_nat_direct_airside_transit_visa
        add_responses purpose_of_visit?: "marriage"

        assert_rendered_outcome text: "You’ll need a visa to come to the UK"
        assert_no_rendered_outcome text: "If you want to convert a civil partnership into a marriage"
      end
    end

    context "No 12: outcome_school_y" do
      should "not render transition text" do
        testing_node :outcome_school_y
        add_responses purpose_of_visit?: "school"

        assert_rendered_outcome text: "You’ll need a visa to stay with your child"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end

    context "No 13: outcome_medical_y" do
      should "not render transition text" do
        testing_node :outcome_medical_y
        add_responses purpose_of_visit?: "medical"

        assert_rendered_outcome text: "You’ll need a visa to visit the UK"
        assert_no_rendered_outcome text: "If you’re arriving in the UK before 3pm (UK time) on 24 December 2024"
      end
    end
  end
end
