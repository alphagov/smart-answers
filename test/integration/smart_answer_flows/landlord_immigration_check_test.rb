require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/landlord-immigration-check"

class LandlordImmigrationCheckFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::LandlordImmigrationCheckFlow
    stub_imminence_has_areas_for_postcode("PA3%202SW", [{ type: "EUR", name: "Scotland", country_name: "Scotland" }])
    stub_imminence_has_areas_for_postcode("B1%201PW", [{ type: "EUR", name: "West Midlands", country_name: "England" }])
  end

  should "start by asking first question" do
    assert_current_node :property?
  end

  should "lead to outcome_check_not_needed" do
    add_response "PA3 2SW"
    assert_current_node :outcome_check_not_needed
  end

  should "lead to main_home" do
    add_response "B1 1PW" # property
    assert_current_node :main_home?
  end

  should "lead to tenant_over_18" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    assert_current_node :tenant_over_18?
  end

  should "lead to what_nationality" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "yes" # tenant_over_18
    assert_current_node :what_nationality?
  end

  should "lead to outcome_check_not_needed_if_holiday_or_under_3_months" do
    add_response "B1 1PW" # property
    add_response "no" # main_home
    add_response "holiday_accommodation" # property_type
    assert_current_node :outcome_check_not_needed_if_holiday_or_under_3_months
  end

  should "lead to outcome_check_needed_if_break_clause" do
    add_response "B1 1PW" # property
    add_response "no" # main_home
    add_response "7_year_lease_property" # property_type
    assert_current_node :outcome_check_needed_if_break_clause
  end

  should "lead to outcome_check_not_needed_when_mobile_home" do
    add_response "B1 1PW" # property
    add_response "no" # main_home
    add_response "mobile_home" # property_type
    assert_current_node :outcome_check_not_needed_when_mobile_home
  end

  should "lead to outcome_check_may_be_needed_when_student" do
    add_response "B1 1PW" # property
    add_response "no" # main_home
    add_response "student_accommodation" # property_type
    assert_current_node :outcome_check_may_be_needed_when_student
  end

  should "lead to outcome_check_not_needed_when_under_18" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "no" # tenant_over_18
    assert_current_node :outcome_check_not_needed_when_under_18
  end

  should "lead to outcome_can_rent" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "yes" # tenant_over_18
    add_response "eea" # what_nationality
    add_response "yes" # has_uk_passport
    assert_current_node :outcome_can_rent
  end

  context "LandlordImmigrationCheckFlow" do
    setup do
      add_response "B1 1PW" # property
      add_response "yes" # main_home
      add_response "yes" # tenant_over_18
    end

    should "go to what_nationality outcome" do
      assert_current_node :what_nationality?
    end

    context "when tenant is british or irish" do
      setup do
        add_response "british-or-irish" # what_nationality?
      end

      should "go to has_uk_passport if british or irish is selected" do
        assert_current_node :has_uk_passport?
      end

      should "go to outcome_can_rent if tenant has british or irish passport" do
        add_response "yes" # has_uk_passport?
        assert_current_node :outcome_can_rent
      end

      should "go to has_other_documents if tenant hasn't got british or irish passport" do
        add_response "no" # has_uk_passport?
        assert_current_node :has_other_documents?
      end

      should "go to outcome_can_rent if tenant has got other documents" do
        add_response "no" # has_uk_passport?
        add_response "yes" # has_other_documents?
        assert_current_node :outcome_can_rent
      end

      should "go to waiting_for_documents if tenant hasn't got other documents" do
        add_response "no" # has_uk_passport?
        add_response "no" # has_other_documents?
        assert_current_node :outcome_can_not_rent
      end
    end

    context "when tenant is from eea" do
      setup do
        add_response "eea" # what_nationality?
      end

      should "go to has_eu_documents if EEA is selected" do
        assert_current_node :has_eu_documents?
      end

      should "go to outcome_can_rent if tenant has EEA passport" do
        add_response "yes" # has_eu_documents?
        assert_current_node :outcome_can_rent
      end

      should "go to has_other_documents if tenant hasn't got EEA passport" do
        add_response "no" # has_eu_documents?
        assert_current_node :has_other_documents?
      end

      should "go to outcome_can_rent if tenant has got other documents" do
        add_response "no" # has_eu_documents?
        add_response "yes" # has_other_documents?
        assert_current_node :outcome_can_rent
      end

      should "go to waiting_for_documents if tenant hasn't got other documents" do
        add_response "no" # has_eu_documents?
        add_response "no" # has_other_documents?
        assert_current_node :outcome_can_not_rent
      end
    end

    context "when tenant is non-EEA family member" do
      setup do
        add_response "non-eea"
      end

      should "go to family_permit" do
        assert_current_node :family_permit?
      end

      should "go to outcome_can_rent if tenant has a permanent residence card" do
        add_response "yes" # family_permit?
        assert_current_node :outcome_can_rent
      end

      should "ask if tenant has residence card for EU, EEA or Swiss family member" do
        add_response "no" # family_permit?
        assert_current_node :has_residence_card_or_eu_eea_swiss_family_member?
      end

      should "go to outcome_can_rent_but_check_will_be_needed_again if tenant has residence card for EU, EEA or Swiss family member" do
        add_response "no"  # family_permit?
        add_response "yes" # has_residence_card_or_eu_eea_swiss_family_member?
        assert_current_node :outcome_can_rent_but_check_will_be_needed_again
      end

      should "go to question has_documents? if tenant does have a residence card for EU, EEA or Swiss family member" do
        add_response "no"  # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        assert_current_node :has_documents?
      end

      should "go to outcome_can_rent if tenant answers yes to has_documents?" do
        add_response "no" # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "yes" # has_documents?
        assert_current_node :outcome_can_rent
      end

      should "go to outcome_can_rent if tenant answers no to has_documents?" do
        add_response "no"  # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        assert_current_node :time_limited_to_remain?
      end

      should "go to outcome_can_rent_but_check_will_be_needed_again if tenant has time limited leave to remain" do
        add_response "no" # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        add_response "yes" # time_limited_to_remain?
        assert_current_node :outcome_can_rent_but_check_will_be_needed_again
      end

      should "go to has_other_documents? if tenant does not have time limited leave to remain" do
        add_response "no"  # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        add_response "no" # time_limited_to_remain?
        assert_current_node :has_other_documents?
      end

      should "go to outcome_can_rent if tenant answers yes to has_other_documents?" do
        add_response "no" # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        add_response "no" # time_limited_to_remain?
        add_response "yes" # has_other_documents?
        assert_current_node :outcome_can_rent
      end

      should "go to question waiting_for_documents if tenant answers no to has_other_documents?" do
        add_response "no"  # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        add_response "no" # time_limited_to_remain?
        add_response "no" # has_other_documents?
        assert_current_node :waiting_for_documents?
      end

      should "go to outcome_landlords_checking_service if tenant answers yes to waiting_for_documents?" do
        add_response "no" # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        add_response "no" # time_limited_to_remain?
        add_response "no" # has_other_documents?
        add_response "yes" # waiting_for_documents?
        assert_current_node :outcome_landlords_checking_service
      end

      should "go to question permission to rent if tenant answers no to waiting_for_documents?" do
        add_response "no"  # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        add_response "no" # time_limited_to_remain?
        add_response "no" # has_other_documents?
        add_response "no" # waiting_for_documents?
        assert_current_node :immigration_application?
      end

      should "go to outcome_landlords_checking_service if tenant has special permission to rent" do
        add_response "no" # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        add_response "no" # time_limited_to_remain?
        add_response "no" # has_other_documents?
        add_response "no" # waiting_for_documents?
        add_response "yes" # immigration_application?
        assert_current_node :outcome_landlords_checking_service
      end

      should "go to outcome_can_not_rent if tenant answers does not have special permission to rent" do
        add_response "no"  # family_permit?
        add_response "no" # has_residence_card_or_eu_eea_swiss_family_member?
        add_response "no" # has_documents?
        add_response "no" # time_limited_to_remain?
        add_response "no" # has_other_documents?
        add_response "no" # waiting_for_documents?
        add_response "no" # immigration_application?
        assert_current_node :outcome_can_not_continue_renting
      end
    end

    context "when tenant is from somewhere else or you don't know" do
      setup do
        add_response "somewhere-else"
      end

      should "go to has_uk_passport" do
        assert_current_node :has_uk_passport?
      end

      should "go to outcome_can_rent is user selects yes in has_uk_passport" do
        add_response "yes"

        assert_current_node :outcome_can_rent
      end

      should "go to has_eu_documents" do
        add_response "no"

        assert_current_node :has_eu_documents?
      end

      should "go to outcome_can_rent is user selects yes in has_eu_documents" do
        add_response "no"
        add_response "yes"

        assert_current_node :outcome_can_rent
      end

      should "go to family_permit" do
        add_response "no"
        add_response "no"

        assert_current_node :family_permit?
      end

      should "go to outcome_can_not_continue_renting" do
        add_response "no"
        add_response "no"
        add_response "no"
        add_response "no"
        add_response "no"
        add_response "no"
        add_response "no"
        add_response "no"
        add_response "no"
        add_response "no"

        assert_current_node :outcome_can_not_continue_renting
      end
    end
  end

  should "lead to outcome_can_not_rent" do
    add_response "B1 1PW" # property
    add_response "yes" # main_home
    add_response "yes" # tenant_over_18
    add_response "eea" # what_nationality
    add_response "no" # has_eu_documents?
    add_response "no" # has_other_documents?
    assert_current_node :outcome_can_not_rent
  end
end
