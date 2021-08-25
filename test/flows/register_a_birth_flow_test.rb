require "test_helper"
require "support/flow_test_helper"

class RegisterABirthFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  def stub_worldwide_locations
    locations = %w[
      algeria
      andorra
      belgium
      cambodia
      cameroon
      denmark
      finland
      france
      india
      indonesia
      ireland
      israel
      italy
      japan
      jordan
      kenya
      libya
      monaco
      morocco
      nepal
      netherlands
      nigeria
      north-korea
      papua-new-guinea
      philippines
      poland
      portugal
      russia
      sierra-leone
      somalia
      south-korea
      spain
      sri-lanka
      sudan
      sweden
      united-arab-emirates
      taiwan
      the-occupied-palestinian-territories
      turkey
      uganda
      usa
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

  context "outcome: oru_result" do
    setup do
      testing_node :oru_result
      add_responses country_of_birth?: "italy",
                    who_has_british_nationality?: "mother",
                    married_couple_or_civil_partnership?: "yes",
                    childs_date_of_birth?: "2006-07-01",
                    where_are_you_now?: "in_the_uk"
    end

    should "render court order guidance if birth registered in Indonesia, father is british and parents not married or in civil partnership" do
      add_responses who_has_british_nationality?: "father",
                    married_couple_or_civil_partnership?: "no",
                    where_are_you_now?: "another_country",
                    which_country?: "indonesia"
      assert_rendered_outcome text: "You’ll need to get a court order"
    end

    should "render Libya guidance if birth registered in Libya" do
      add_responses where_are_you_now?: "another_country",
                    which_country?: "libya"
      assert_rendered_outcome text: "You cannot apply for a passport in Libya"
    end

    should "render passport guidance if child not born in higher risk country" do
      assert_rendered_outcome text: "You can also register the birth with the UK authorities. You must:"
    end

    should "render Morocco guidance if child born in Morocco and parents not married or in civil partnership" do
      add_responses country_of_birth?: "morocco",
                    married_couple_or_civil_partnership?: "no",
                    where_are_you_now?: "same_country"
      assert_rendered_outcome text: "To add the father’s name you must swear a paternity declaration in a Moroccan court and you may be ordered to get married."
    end

    should "render Andorra guidance if child born in Andorra" do
      add_responses country_of_birth?: "andorra"
      assert_rendered_outcome text: "declaració de naixement"
    end

    should "render Belgium guidance if child born in Belgium" do
      add_responses country_of_birth?: "belgium"
      assert_rendered_outcome text: "copie d’acte’ or ‘afschrift van een akte"
    end

    should "render Denmark guidance if child born in Denmark" do
      add_responses country_of_birth?: "denmark"
      assert_rendered_outcome text: "fødsel og navneattest"
    end

    should "render Finland guidance if child born in Finland" do
      add_responses country_of_birth?: "finland"
      assert_rendered_outcome text: "an extract in English from the Population Information System which has the name of the child and the parents"
    end

    should "render France guidance if child born in France" do
      add_responses country_of_birth?: "france"
      assert_rendered_outcome text: "copie integrale acte de naissance"
    end

    should "render India guidance if child born in India" do
      add_responses country_of_birth?: "india"
      assert_rendered_outcome text: "the hospital discharge summary (a letter from the hospital saying what treatment you had)"
    end

    should "render Israel guidance if child born in Israel" do
      add_responses country_of_birth?: "israel"
      assert_rendered_outcome text: "the hospital live birth certificate (if the father is not named on the local birth certificate)"
    end

    should "render Italy guidance if child born in Italy" do
      assert_rendered_outcome text: "the child’s long international birth certificate (not the standard short version)"
    end

    should "render Japan guidance if child born in Japan" do
      add_responses country_of_birth?: "japan"
      assert_rendered_outcome text: "shussetodoke kisaijiko shomeisho"
    end

    should "render Monaco guidance if child born in Monaco" do
      add_responses country_of_birth?: "monaco"
      assert_rendered_outcome text: "copie integrale acte de naissance"
    end

    should "render Morocco guidance if child born in Morocco" do
      add_responses country_of_birth?: "morocco"
      assert_rendered_outcome text: "how you would like the child’s full name to be registered, if the name differs from the name on the local birth certificate"
    end

    should "render Nepal guidance if child born in Nepal" do
      add_responses country_of_birth?: "nepal"
      assert_rendered_outcome text: "one parent is Nepali"
    end

    should "render Netherlands guidance if child born in Netherlands" do
      add_responses country_of_birth?: "netherlands"
      assert_rendered_outcome text: "akte van geboorte"
    end

    should "render Nigeria guidance if child born in Nigeria" do
      add_responses country_of_birth?: "nigeria"
      assert_rendered_outcome text: "the mother’s antenatal records (eg blood test results, ultrasound scans and doctors’ notes)"
    end

    should "render Poland guidance if child born in Poland" do
      add_responses country_of_birth?: "poland"
      assert_rendered_outcome text: "zupelny"
    end

    should "render Portugal guidance if child born in Portugal" do
      add_responses country_of_birth?: "portugal"
      assert_rendered_outcome text: "assento de nascimento"
    end

    should "render Russia guidance if child born in Russia" do
      add_responses country_of_birth?: "russia"
      assert_rendered_outcome text: "the child’s full local birth certificate - it must have both parents’ names"
    end

    should "render Sierra Leone documents guidance if child born in Sierra Leone" do
      add_responses country_of_birth?: "sierra-leone"
      assert_rendered_outcome text: "the child’s full local birth certificate - it must have both parents’ names"
    end

    should "render South Korea guidance if child born in South Korea" do
      add_responses country_of_birth?: "south-korea"
      assert_rendered_outcome text: "gi bon jung myung seo"
    end

    should "render Spain guidance if child born in Spain" do
      add_responses country_of_birth?: "spain"
      assert_rendered_outcome text: "certificación literal"
    end

    should "render Sri Lanka guidance if child born in Sri Lanka" do
      add_responses country_of_birth?: "sri-lanka"
      assert_rendered_outcome text: "the child’s full local birth certificate - it must have both parents’ names"
    end

    should "render Sweden guidance if child born in Sweden" do
      add_responses country_of_birth?: "sweden"
      assert_rendered_outcome text: "Swedish Tax Agency (Skatteverket)"
    end

    should "render United Arab Emirates guidance if child born in United Arab Emirates" do
      add_responses country_of_birth?: "united-arab-emirates"
      assert_rendered_outcome text: "both English and Arabic versions of your child’s full local birth certificate"
    end

    should "render Taiwan guidance if child born in Taiwan" do
      add_responses country_of_birth?: "taiwan"
      assert_rendered_outcome text: "both Chinese and English versions of the child’s birth certificate"
    end

    should "render The Occupied Palestinian Territories guidance if child born in The Occupied Palestinian Territories" do
      add_responses country_of_birth?: "the-occupied-palestinian-territories"
      assert_rendered_outcome text: "the hospital declaration of live birth (if the father isn’t named on the birth certificate)"
    end

    should "render Turkey guidance if child born in Turkey" do
      add_responses country_of_birth?: "turkey"
      assert_rendered_outcome text: "Formül A"
    end

    should "render USA guidance if child born in USA" do
      add_responses country_of_birth?: "usa"
      assert_rendered_outcome text: "hospital, medical or insurance records naming the parents as the birth parents"
    end

    should "render standard birth certificate guidance if child not born in documents variant country" do
      add_responses country_of_birth?: "philippines"
      assert_rendered_outcome text: "the child’s full local birth certificate - it must have both parents’ names"
    end

    should "render Philippines guidance if child born in Philippines and mother is not British" do
      add_responses country_of_birth?: "philippines",
                    who_has_british_nationality?: "father"
      assert_rendered_outcome text: "the Filipino mother is single"
    end

    should "render Philippines guidance if child born in Philippines" do
      add_responses country_of_birth?: "philippines"
      assert_rendered_outcome text: "photos of the child as a baby, in which the child can clearly be identified with its parents in the Philippines"
    end

    should "render Sierra Leone guidance if child born in Sierra Leone" do
      add_responses country_of_birth?: "sierra-leone"
      assert_rendered_outcome text: "photos of the child as a baby, in which the child can clearly be identified with its parents in Sierra Leone"
    end

    should "render Uganda guidance if child born in Uganda" do
      add_responses country_of_birth?: "uganda"
      assert_rendered_outcome text: "photos of the child as a baby, in which the child can clearly be identified with its parents in Uganda"
    end

    should "render payment information for Algeria if birth registered in Algeria" do
      add_responses where_are_you_now?: "another_country",
                    which_country?: "algeria"
      assert_rendered_outcome text: "Pay by credit or debit card"
    end

    should "render payment information for Sudan if birth registered in Sudan" do
      add_responses where_are_you_now?: "another_country",
                    which_country?: "sudan"
      assert_rendered_outcome text: "you can also pay in person at the Consular section of the British Embassy, Khartoum"
    end

    should "render generic payment guidance if birth not registered in Algeria or Sudan" do
      assert_rendered_outcome text: "You should pay online for the registration"
    end

    should "render registration address for registering birth from the UK" do
      assert_rendered_outcome text: "MK11 9NS"
    end

    should "render registration address for registering birth from outside the UK" do
      add_responses where_are_you_now?: "same_country"
      assert_rendered_outcome text: "MK19 7BH"
    end

    should "render custom waiting time guidance if child born in country that does not need a DNA test but has a waiting time" do
      add_responses country_of_birth?: "nigeria"
      assert_rendered_outcome text: "If this happens then it could take longer for the birth to be registered"
    end

    should "render North Korea documents guidance if child born in North Korea but currently in another country" do
      add_responses country_of_birth?: "north-korea",
                    where_are_you_now?: "in_the_uk"
      assert_rendered_outcome text: "Registration can take up to 3 months"
    end

    should "render generic documents guidance if child not born in North Korea and no wait time" do
      assert_rendered_outcome text: "If this happens then it could take up to 3 months for the birth to be registered"
    end

    should "render Cambodia guidance if birth registered in Cambodia and not currently in the UK" do
      add_responses country_of_birth?: "cambodia",
                    where_are_you_now?: "same_country"
      assert_rendered_outcome text: "British Embassy in Phnom Penh"
    end

    should "render Kenya guidance if birth registered in Kenya and not currently in the UK" do
      add_responses country_of_birth?: "kenya",
                    where_are_you_now?: "same_country"
      assert_rendered_outcome text: "British High Commission in Nairobi"
    end

    should "render Cameroon guidance if birth registered in Cameroon and not currently in the UK" do
      add_responses country_of_birth?: "cameroon",
                    where_are_you_now?: "same_country"
      assert_rendered_outcome text: "British High Commission in Yaonde"
    end

    should "render Nigeria guidance if birth registered in Nigeria and not currently in the UK" do
      add_responses country_of_birth?: "nigeria",
                    where_are_you_now?: "same_country"
      assert_rendered_outcome text: "British High Commission in Lagos"
    end

    should "render Papua New Guinea guidance if birth registered in Papua New Guinea and not currently in the UK" do
      add_responses country_of_birth?: "papua-new-guinea",
                    where_are_you_now?: "same_country"
      assert_rendered_outcome text: "British Embassy in Port Moresby"
    end

    should "render Uganda guidance if birth registered in Uganda and not currently in the UK" do
      add_responses country_of_birth?: "uganda",
                    where_are_you_now?: "same_country"
      assert_rendered_outcome text: "British High Commission in Kampala"
    end

    should "render registration certificate copies guidance if birth not registered in country where documents couriered by High Commission" do
      assert_rendered_outcome text: "You’ll also be sent copies of the registration certificate if you’ve paid for them"
    end

    should "render generic document return guidance if currently in the uk" do
      assert_rendered_outcome text: "Your documents will be returned to you by secure courier after the birth has been registered"
    end
  end
end
