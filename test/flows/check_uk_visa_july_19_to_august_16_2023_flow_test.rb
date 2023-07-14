require "test_helper"
require "support/flow_test_helper"
require "support/flows/check_uk_visa_flow_test_helper"

class CheckUkVisaJuly13ToAugust102023FlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  extend CheckUkVisaFlowTestHelper

  setup do
    testing_flow CheckUkVisaFlow
    stub_worldwide_api_has_locations(
      %w[dominica honduras namibia timor-leste vanuatu india].uniq,
    )
  end

  context "Outcomes: for a July 13 to August 10 2023 grace period country" do
    %w[dominica honduras namibia timor-leste vanuatu].each do |country|
      context "No 1: outcome_tourism_visa_partner" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_tourism_visa_partner
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "tourism",
                        travelling_visiting_partner_family_member?: "yes"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You can stay in the UK as a tourist for up to 6 months without a visa if all the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_tourism_visa_partner
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "tourism",
                        travelling_visiting_partner_family_member?: "yes"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You can stay in the UK as a tourist for up to 6 months without a visa if all the following apply:"
        end
      end

      context "No 2: outcome_standard_visitor_visa" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_standard_visitor_visa
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "tourism",
                        travelling_visiting_partner_family_member?: "no"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You can stay in the UK as a tourist for up to 6 months without a visa if all the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_standard_visitor_visa
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "tourism",
                        travelling_visiting_partner_family_member?: "no"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You can stay in the UK as a tourist for up to 6 months without a visa if all the following apply:"
        end
      end

      context "No 3: outcome_work_m" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_work_m
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "work",
                        staying_for_how_long?: "six_months_or_less"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You may be able to come to the UK without a visa if both of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_work_m
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "work",
                        staying_for_how_long?: "six_months_or_less"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You may be able to come to the UK without a visa if both of the following apply:"
        end
      end

      context "No 4: outcome_study_m" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_study_m
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "study",
                        staying_for_how_long?: "six_months_or_less"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You can stay in the UK as a student for up to 6 months without a visa if all the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_study_m
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "study",
                        staying_for_how_long?: "six_months_or_less"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You can stay in the UK as a student for up to 6 months without a visa if all the following apply:"
        end
      end

      context "No 5: outcome_transit_to_the_republic_of_ireland" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_transit_to_the_republic_of_ireland
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "transit",
                        travelling_to_cta?: "republic_of_ireland"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You do not need a visa to come to the UK if both of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_transit_to_the_republic_of_ireland
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "transit",
                        travelling_to_cta?: "republic_of_ireland"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You do not need a visa to come to the UK if both of the following apply:"
        end
      end

      context "No 6: outcome_transit_leaving_airport_direct_airside_transit_visa" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_transit_leaving_airport_direct_airside_transit_visa
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "transit",
                        travelling_to_cta?: "somewhere_else",
                        passing_through_uk_border_control?: "yes"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You do not need a visa to come to the UK if both of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_transit_leaving_airport_direct_airside_transit_visa
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "transit",
                        travelling_to_cta?: "somewhere_else",
                        passing_through_uk_border_control?: "yes"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You do not need a visa to come to the UK if both of the following apply:"
        end
      end

      context "No 7: outcome_transit_not_leaving_airport" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_transit_not_leaving_airport
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "transit",
                        travelling_to_cta?: "somewhere_else",
                        passing_through_uk_border_control?: "no"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You do not need a visa to come to the UK if both of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_transit_not_leaving_airport
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "transit",
                        travelling_to_cta?: "somewhere_else",
                        passing_through_uk_border_control?: "no"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You do not need a visa to come to the UK if both of the following apply:"
        end
      end

      context "No 8: outcome_partner_family_british_citizen_y" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_partner_family_british_citizen_y
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "family",
                        partner_family_british_citizen?: "yes"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You can join your partner or family member for up to 6 months without a visa if both of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_partner_family_british_citizen_y
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "family",
                        partner_family_british_citizen?: "yes"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You can join your partner or family member for up to 6 months without a visa if both of the following apply:"
        end
      end

      context "No 9: outcome_partner_family_eea_y" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_partner_family_eea_y
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "family",
                        partner_family_british_citizen?: "no",
                        partner_family_eea?: "yes"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You can join your partner or family member for up to 6 months without a visa if both of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_partner_family_eea_y
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "family",
                        partner_family_british_citizen?: "no",
                        partner_family_eea?: "yes"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You can join your partner or family member for up to 6 months without a visa if both of the following apply:"
        end
      end

      context "No 10: outcome_partner_family_eea_n" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_partner_family_eea_n
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "family",
                        partner_family_british_citizen?: "no",
                        partner_family_eea?: "no"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You can join your partner or family member for up to 6 months without a visa if both of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_partner_family_eea_n
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "family",
                        partner_family_british_citizen?: "no",
                        partner_family_eea?: "no"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You can join your partner or family member for up to 6 months without a visa if both of the following apply:"
        end
      end

      context "No 11: outcome_marriage_visa_nat_direct_airside_transit_visa" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_marriage_visa_nat_direct_airside_transit_visa
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "marriage"
          assert_rendered_outcome text: "If you want to convert a civil partnership into a marriage"
          assert_rendered_outcome text: "You can come to the UK for up to 6 months without a visa if all of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_marriage_visa_nat_direct_airside_transit_visa
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "marriage"
          assert_no_rendered_outcome text: "If you want to convert a civil partnership into a marriage"
          assert_no_rendered_outcome text: "You can come to the UK for up to 6 months without a visa if all of the following apply:"
        end
      end

      context "No 12: outcome_school_y" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_school_y
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "school"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You can stay in the UK for up to 6 months without a visa if all of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_school_y
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "school"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You can stay in the UK for up to 6 months without a visa if all of the following apply:"
        end
      end

      context "No 13: outcome_medical_y" do
        should "render if arriving in the UK before 16 August 2023 when country is #{country}" do
          testing_node :outcome_medical_y
          add_responses what_passport_do_you_have?: country,
                        purpose_of_visit?: "medical"
          assert_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_rendered_outcome text: "You can stay in the UK for up to 6 months without a visa if all of the following apply:"
        end

        should "render if arriving in the UK before 16 August 2023 when country is india" do
          testing_node :outcome_medical_y
          add_responses what_passport_do_you_have?: "india",
                        purpose_of_visit?: "medical"
          assert_no_rendered_outcome text: "If you’re arriving in the UK before 16 August 2023"
          assert_no_rendered_outcome text: "You can stay in the UK for up to 6 months without a visa if all of the following apply:"
        end
      end
    end
  end
end
