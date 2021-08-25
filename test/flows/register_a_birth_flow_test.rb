require "test_helper"
require "support/flow_test_helper"

class RegisterABirthFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  def stub_worldwide_locations
    locations = %w[
      ireland
      italy
      jordan
      north-korea
      yemen
    ]
    stub_worldwide_api_has_locations(locations)
    stub_worldwide_api_has_organisations_for_location("north-korea", { results: [{ title: "organisation-title" }] })
  end

  setup do
    testing_flow RegisterABirthFlow
    stub_worldwide_locations
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: country_of_birth?" do
    setup { testing_node :country_of_birth? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of no_embassy_result for any for any country without an embassy" do
        assert_next_node :no_embassy_result, for_response: "yemen"
      end

      should "have a next node of nonregistrable_result for any nonregistrable country" do
        assert_next_node :nonregistrable_result, for_response: "ireland"
      end

      should "have a next node of who_has_british_nationality? for any country registable country with an embassy" do
        assert_next_node :who_has_british_nationality?, for_response: "italy"
      end
    end
  end

  context "question: who_has_british_nationality?" do
    setup do
      testing_node :who_has_british_nationality?
      add_responses country_of_birth?: "italy"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      %w[mother father mother_and_father].each do |parent|
        should "have a next node of married_couple_or_civil_partnership? for a '#{parent}' response" do
          assert_next_node :married_couple_or_civil_partnership?, for_response: parent
        end
      end

      should "have a next node of no_registration_result for a 'neither' response" do
        assert_next_node :no_registration_result, for_response: "neither"
      end
    end
  end

  context "question: married_couple_or_civil_partnership?" do
    setup do
      testing_node :married_couple_or_civil_partnership?
      add_responses country_of_birth?: "italy",
                    who_has_british_nationality?: "mother"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of childs_date_of_birth? for a 'no' response if only child's father is British" do
        add_responses who_has_british_nationality?: "father"
        assert_next_node :childs_date_of_birth?, for_response: "no"
      end

      should "have a next_node of where_are_you_now? for a 'yes' response" do
        assert_next_node :where_are_you_now?, for_response: "yes"
      end
    end
  end

  context "question: childs_date_of_birth?" do
    setup do
      testing_node :childs_date_of_birth?
      add_responses country_of_birth?: "italy",
                    who_has_british_nationality?: "father",
                    married_couple_or_civil_partnership?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next_node of homeoffice_result for any response before 1st July 2006" do
        assert_next_node :homeoffice_result, for_response: "2006-06-30"
      end

      should "have a next_node of where_are_you_now? for any response on or after 1st July 2006" do
        assert_next_node :where_are_you_now?, for_response: "2006-07-01"
      end
    end
  end

  context "question: where_are_you_now?" do
    setup do
      testing_node :where_are_you_now?
      add_responses country_of_birth?: "italy",
                    who_has_british_nationality?: "mother",
                    married_couple_or_civil_partnership?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next_node of no_birth_certificate_result for any response for country with birth registration exception and if parents not married or civil partners" do
        add_responses country_of_birth?: "jordan",
                      married_couple_or_civil_partnership?: "no"
        assert_next_node :no_birth_certificate_result, for_response: "same_country"
      end

      should "have a next_node of which_country? for an 'another_country' response" do
        assert_next_node :which_country?, for_response: "another_country"
      end

      should "have a next_node of north_korea_result for a 'same_country' response if child born in North Korea" do
        add_responses country_of_birth?: "north-korea"
        assert_next_node :north_korea_result, for_response: "same_country"
      end

      should "have a next_node of oru_result for a 'same_country' response for country without birth registration exception" do
        assert_next_node :oru_result, for_response: "same_country"
      end

      should "have a next_node of oru_result for a 'in_the_uk' response" do
        assert_next_node :oru_result, for_response: "in_the_uk"
      end
    end
  end

  context "question: which_country?" do
    setup do
      testing_node :which_country?
      add_responses country_of_birth?: "italy",
                    who_has_british_nationality?: "mother",
                    married_couple_or_civil_partnership?: "yes",
                    where_are_you_now?: "another_country"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next_node of north_korea_result for a 'north-korea' response" do
        assert_next_node :north_korea_result, for_response: "north-korea"
      end

      should "have a next_node of oru_result for any response not 'north-korea'" do
        assert_next_node :oru_result, for_response: "ireland"
      end
    end
  end

  context "outcome: north_korea_result" do
    setup do
      testing_node :north_korea_result
      add_responses country_of_birth?: "north-korea",
                    who_has_british_nationality?: "mother",
                    married_couple_or_civil_partnership?: "yes",
                    where_are_you_now?: "same_country"
    end

    should "render mother only guidance if parents not married or have civil partnership" do
      add_responses married_couple_or_civil_partnership?: "no"
      assert_rendered_outcome text: "The mother must register the birth."
    end

    should "render either parent guidance if parents married or have civil partnership" do
      assert_rendered_outcome text: "Either parent can register the birth."
    end
  end
end
