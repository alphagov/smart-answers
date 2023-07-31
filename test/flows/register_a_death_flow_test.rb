require "test_helper"
require "support/flow_test_helper"

class RegisterADeathFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  def stub_worldwide_locations
    locations = %w[
      algeria
      cambodia
      cameroon
      ireland
      italy
      kenya
      nigeria
      north-korea
      papua-new-guinea
      poland
      uganda
      yemen
    ]
    stub_worldwide_api_has_locations(locations)
    stub_search_api_has_organisations_for_location("north-korea", [{ "title" => "organisation-title", "base_path" => "/world/organisations/organisation" }])
  end

  setup do
    testing_flow RegisterADeathFlow
    stub_worldwide_locations
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: where_did_the_death_happen?" do
    setup { testing_node :where_did_the_death_happen? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of scotland_result for a 'scotland' response" do
        assert_next_node :scotland_result, for_response: "scotland"
      end

      should "have a next node of northern_ireland_result for a 'northern_ireland' response" do
        assert_next_node :northern_ireland_result, for_response: "northern_ireland"
      end

      should "have a next node of did_the_person_die_at_home_hospital? for a 'england_wales' response" do
        assert_next_node :did_the_person_die_at_home_hospital?, for_response: "england_wales"
      end

      should "have a next node of which_country? for a 'overseas' response" do
        assert_next_node :which_country?, for_response: "overseas"
      end
    end
  end

  context "question: did_the_person_die_at_home_hospital?" do
    setup do
      testing_node :did_the_person_die_at_home_hospital?
      add_responses where_did_the_death_happen?: "england_wales"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of was_death_expected? for any response" do
        assert_next_node :was_death_expected?, for_response: "at_home_hospital"
      end
    end
  end

  context "question: was_death_expected?" do
    setup do
      testing_node :was_death_expected?
      add_responses where_did_the_death_happen?: "england_wales",
                    did_the_person_die_at_home_hospital?: "at_home_hospital"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of uk_result for any response" do
        assert_next_node :uk_result, for_response: "yes"
      end
    end
  end

  context "question: which_country?" do
    setup do
      testing_node :which_country?
      add_responses where_did_the_death_happen?: "overseas"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nonregistrable_result for any nonregistrable country" do
        assert_next_node :nonregistrable_result, for_response: "ireland"
      end

      should "have a next node of no_embassy_result for any country without an embassy" do
        assert_next_node :no_embassy_result, for_response: "yemen"
      end

      should "have a next node of where_are_you_now? for any country registable country with an embassy" do
        assert_next_node :where_are_you_now?, for_response: "italy"
      end
    end
  end

  context "question: where_are_you_now?" do
    setup do
      testing_node :where_are_you_now?
      add_responses where_did_the_death_happen?: "overseas",
                    which_country?: "italy"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of north_korea_result for a 'same_country' response if died in North Korea" do
        add_responses which_country?: "north-korea"

        assert_next_node :north_korea_result, for_response: "same_country"
      end

      should "have a next node of oru_result for a 'same_country' response and did not die in North Korea" do
        assert_next_node :oru_result, for_response: "same_country"
      end

      should "have a next node of which_country_are_you_in_now? for a 'another_country' response" do
        assert_next_node :which_country_are_you_in_now?, for_response: "another_country"
      end

      should "have a next node of oru_result for a 'in_the_uk' response" do
        assert_next_node :oru_result, for_response: "in_the_uk"
      end
    end
  end

  context "question: which_country_are_you_in_now?" do
    setup do
      testing_node :which_country_are_you_in_now?
      add_responses where_did_the_death_happen?: "overseas",
                    which_country?: "italy",
                    where_are_you_now?: "another_country"
    end

    should "render the question" do
      assert_rendered_question
    end

    should "have a next node of north_korea_result for a 'north-korea' response" do
      assert_next_node :north_korea_result, for_response: "north-korea"
    end

    should "have a next node of oru_result for anyy response that is not North Korea" do
      assert_next_node :oru_result, for_response: "ireland"
    end
  end

  context "outcome: nonregistrable_result" do
    setup do
      testing_node  :nonregistrable_result
      add_responses where_did_the_death_happen?: "overseas"
    end

    should "render Tell us Once guidance if death occurred in a non-registable EEA Country" do
      add_responses which_country?: "ireland",
                    where_are_you_now?: "same_country"
      assert_rendered_outcome text: "Tell Us Once service"
    end

    should "render Tell us Once guidance if death occurred in a non-registable Commonwealth country" do
      add_responses which_country?: "ireland"
      assert_rendered_outcome text: "Tell Us Once service"
    end
  end

  context "outcome: oru_result" do
    setup do
      testing_node  :oru_result
      add_responses where_did_the_death_happen?: "overseas",
                    which_country?: "italy",
                    where_are_you_now?: "same_country"
    end

    should "render Tell us Once guidance if death occurred in an EEA Country" do
      assert_rendered_outcome text: "Tell Us Once service"
    end

    should "render Tell us Once guidance if death occurred in a Commonwealth country" do
      add_responses which_country?: "nigeria"
      assert_rendered_outcome text: "Tell Us Once service"
    end

    should "render link to translator if translator link exists for country" do
      assert_rendered_outcome text: "Use an approved translator"
    end

    should "render documents variant guidance for Papua New Guinea if death occurred in Papua New Guinea" do
      add_responses which_country?: "papua-new-guinea"
      assert_rendered_outcome text: "the hospital medical death record"
    end

    should "render generic documents guidance if death occurred in country without documents variant" do
      assert_rendered_outcome text: "the original local death certificate (not a certificate issued by a doctor)"
    end

    should "render documents variant guidance for Poland if death occurred in Poland" do
      add_responses which_country?: "poland"
      assert_rendered_outcome text: "zupelny"
    end

    should "render payment information for Alergia if death occurred in Algeria" do
      add_responses which_country?: "algeria"
      assert_rendered_outcome text: "Pay by credit or debit card"
    end

    should "render payment information for rest of the world if death outside UK but not in Algeria" do
      assert_rendered_outcome text: "Pay online for the registration"
    end

    should "render UK registration address if registering death from the UK" do
      add_responses where_are_you_now?: "in_the_uk"
      assert_rendered_outcome text: "MK11 9NS"
    end

    should "render UK address if registering death from outside the UK" do
      assert_rendered_outcome text: "MK19 7BH"
    end

    context "courier variants" do
      should "render guindance for Cambodia if death occurred in Cambodia" do
        add_responses which_country?: "cambodia"
        assert_rendered_outcome text: "British Embassy in Phnom Penh"
      end

      should "render guindance for Cameroon if death occurred in Cameroon" do
        add_responses which_country?: "cameroon"
        assert_rendered_outcome text: "British High Commission in Yaonde"
      end

      should "render guindance for Kenya if death occurred in Kenya" do
        add_responses which_country?: "kenya"
        assert_rendered_outcome text: "British High Commission in Nairobi"
      end

      should "render guindance for Nigeria if death occurred in Nigeria" do
        add_responses which_country?: "nigeria"
        assert_rendered_outcome text: "British High Commission in Lagos"
      end

      should "render guindance for Papua New Guinea if death occurred in Papua New Guinea" do
        add_responses which_country?: "papua-new-guinea"
        assert_rendered_outcome text: "British Embassy in Port Moresby"
      end

      should "render guindance for Uganda if death occurred in Uganda" do
        add_responses which_country?: "uganda"
        assert_rendered_outcome text: "British High Commission in Kampala"
      end

      should "render registration certificate guindance if courier is a variant but is not High Commission" do
        add_responses which_country?: "uganda"
        assert_rendered_outcome text: "You’ll also be sent copies of the registration certificate if you’ve paid for them"
      end

      should "render secure courier guindance if not using a courier variant" do
        assert_rendered_outcome text: "Your documents will be returned to you by secure courier after the death has been registered"
      end
    end
  end
end
