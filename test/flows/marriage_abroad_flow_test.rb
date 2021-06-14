require "test_helper"
require "support/flow_test_helper"

class MarriageAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  CEREMONY_LOCATION_COUNTRIES = %w[finland iceland].freeze
  MARRIAGE_OR_PACS_COUNTRIES = %w[monaco new-caledonia wallis-and-futuna].freeze
  ONE_QUESTION_COUNTRIES = %w[french-guiana french-polynesia guadeloupe martinique mayotte reunion st-pierre-and-miquelon].freeze
  TWO_QUESTION_COUNTRIES = %w[australia croatia cyprus egypt france india ireland japan luxembourg philippines south-africa south-korea thailand turkey usa zimbabwe].freeze
  THREE_QUESTION_COUNTRIES = %w[congo greece italy poland spain switzerland].freeze
  FOUR_QUESTION_COUNTRIES = %w[afghanistan albania algeria american-samoa andorra angola anguilla antigua-and-barbuda argentina armenia aruba austria azerbaijan bahamas bahrain bangladesh barbados belarus belgium belize benin bermuda bhutan bolivia bonaire-st-eustatius-saba bosnia-and-herzegovina botswana brazil british-indian-ocean-territory british-virgin-islands brunei bulgaria burkina-faso burundi cambodia cameroon canada cape-verde cayman-islands central-african-republic chad chile china colombia comoros costa-rica cote-d-ivoire cuba curacao czech-republic democratic-republic-of-the-congo denmark djibouti dominica dominican-republic ecuador el-salvador equatorial-guinea eritrea estonia eswatini ethiopia falkland-islands fiji gabon georgia germany ghana gibraltar grenada guatemala guinea guinea-bissau guyana haiti honduras hong-kong hungary indonesia iran iraq israel jamaica jordan kazakhstan kenya kiribati kosovo kuwait kyrgyzstan laos latvia lebanon lesotho liberia libya liechtenstein lithuania macao madagascar malawi malaysia maldives malta marshall-islands mauritania mauritius mexico micronesia moldova mongolia montenegro montserrat morocco mozambique myanmar namibia nauru nepal netherlands new-zealand nicaragua niger nigeria north-korea north-macedonia norway oman pakistan palau panama papua-new-guinea paraguay peru pitcairn-island portugal qatar romania russia rwanda saint-barthelemy san-marino sao-tome-and-principe saudi-arabia senegal serbia seychelles sierra-leone singapore slovakia slovenia solomon-islands somalia south-georgia-and-the-south-sandwich-islands south-sudan sri-lanka st-helena-ascension-and-tristan-da-cunha st-kitts-and-nevis st-lucia st-maarten st-martin st-vincent-and-the-grenadines sudan suriname sweden syria taiwan tajikistan tanzania the-gambia timor-leste togo tonga trinidad-and-tobago tunisia turkmenistan turks-and-caicos-islands tuvalu uganda ukraine united-arab-emirates uruguay uzbekistan vanuatu venezuela vietnam western-sahara yemen zambia].freeze
  ALL_COUNTRIES = CEREMONY_LOCATION_COUNTRIES + MARRIAGE_OR_PACS_COUNTRIES + ONE_QUESTION_COUNTRIES + TWO_QUESTION_COUNTRIES + THREE_QUESTION_COUNTRIES + FOUR_QUESTION_COUNTRIES

  # These countries use the worldwide organisation API and need an extra stub
  WORLDWIDE_ORGANISATION_API_COUNTRIES = %w[sweden].freeze

  setup { testing_flow MarriageAbroadFlow }

  should "render start page" do
    assert_rendered_start_page
  end

  context "question: country_of_ceremony?" do
    setup do
      testing_node :country_of_ceremony?
      stub_worldwide_api(ALL_COUNTRIES)
    end

    should "render question" do
      assert_rendered_question
    end

    context "validations" do
      should "be invalid for a country that doesn't exist" do
        assert_invalid_response "non-existent-country"
      end

      should "be valid for a country that exists" do
        assert_valid_response ALL_COUNTRIES.sample
      end
    end

    context "next_node" do
      should "have a next_node of partner_opposite_or_same_sex? for a two questions country" do
        assert_next_node :partner_opposite_or_same_sex?, for_response: TWO_QUESTION_COUNTRIES.sample
      end

      should "have a next_node of marriage_or_pacs? for a pacs country" do
        assert_next_node :marriage_or_pacs?, for_response: MARRIAGE_OR_PACS_COUNTRIES.sample
      end

      should "have a next_node of outcome_marriage_abroad_in_country for a french overseas territory" do
        assert_next_node :outcome_marriage_abroad_in_country, for_response: ONE_QUESTION_COUNTRIES.sample
      end

      should "have a next_node of legal_residency? for other countries" do
        assert_next_node :legal_residency?, for_response: THREE_QUESTION_COUNTRIES.sample
      end
    end
  end

  context "question: legal_residency?" do
    setup do
      testing_node :legal_residency?
      stub_worldwide_api(ALL_COUNTRIES)
      add_responses country_of_ceremony?: FOUR_QUESTION_COUNTRIES.sample
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next_node of outcome_marriage_abroad_in_country for a ceremony location country" do
        add_responses country_of_ceremony?: CEREMONY_LOCATION_COUNTRIES.sample
        assert_next_node :outcome_marriage_abroad_in_country, for_response: "uk"
      end

      should "have a next_node of partner_opposite_or_same_sex? for a three questions country" do
        add_responses country_of_ceremony?: THREE_QUESTION_COUNTRIES.sample
        assert_next_node :partner_opposite_or_same_sex?, for_response: "uk"
      end

      should "have a next_node of what_is_your_partners_nationality? for other countries" do
        assert_next_node :what_is_your_partners_nationality?, for_response: "uk"
      end
    end
  end

  context "question: marriage_or_pacs?" do
    setup do
      testing_node :marriage_or_pacs?
      stub_worldwide_api(ALL_COUNTRIES)
      add_responses country_of_ceremony?: MARRIAGE_OR_PACS_COUNTRIES.sample
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next_node of outcome_marriage_abroad_in_country" do
        assert_next_node :outcome_marriage_abroad_in_country, for_response: "marriage"
      end
    end
  end

  context "question: what_is_your_partners_nationality?" do
    setup do
      testing_node :what_is_your_partners_nationality?
      stub_worldwide_api(ALL_COUNTRIES)
      add_responses country_of_ceremony?: FOUR_QUESTION_COUNTRIES.sample,
                    legal_residency?: "uk"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next_node of partner_opposite_or_same_sex?" do
        assert_next_node :partner_opposite_or_same_sex?, for_response: "partner_british"
      end
    end
  end

  context "question: partner_opposite_or_same_sex?" do
    setup do
      testing_node :partner_opposite_or_same_sex?
      stub_worldwide_api(ALL_COUNTRIES)
      add_responses country_of_ceremony?: FOUR_QUESTION_COUNTRIES.sample,
                    legal_residency?: "uk",
                    what_is_your_partners_nationality?: "partner_british"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next_node of partner_opposite_or_same_sex? for a known country" do
        assert_next_node :outcome_marriage_abroad_in_country, for_response: "opposite_sex"
      end

      should "raise an error for an unknown country" do
        stub_worldwide_api(%w[narnia])
        add_responses country_of_ceremony?: "narnia"
        assert_raises(SmartAnswer::Question::Base::NextNodeUndefined) do
          add_response "opposite_sex"
          @test_flow.state
        end
      end
    end
  end

  context "outcome :outcome_marriage_abroad_in_country" do
    setup { testing_node :outcome_marriage_abroad_in_country }

    MARRIAGE_OR_PACS_COUNTRIES.each do |country|
      context "marriage or pacs country: #{country}" do
        setup do
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render a marriage outcome" do
          add_responses marriage_or_pacs?: "marriage"
          assert_rendered_outcome
        end

        should "render a PACS outcome" do
          add_responses marriage_or_pacs?: "pacs"
          assert_rendered_outcome
        end
      end
    end

    CEREMONY_LOCATION_COUNTRIES.each do |country|
      context "ceremony location country: #{country}" do
        setup do
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an outcome where residency is in the ceremony country" do
          add_responses legal_residency?: "ceremony_country"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country" do
          add_responses legal_residency?: "third_country"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK" do
          add_responses legal_residency?: "uk"
          assert_rendered_outcome
        end
      end
    end

    ONE_QUESTION_COUNTRIES.each do |country|
      context "one question country" do
        setup do
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an outcome" do
          assert_rendered_outcome
        end
      end
    end

    TWO_QUESTION_COUNTRIES.each do |country|
      context "two question country: #{country}" do
        setup do
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an opposite sex outcome" do
          add_responses partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render a same sex outcome" do
          add_responses partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end
      end
    end

    THREE_QUESTION_COUNTRIES.each do |country|
      context "three question country: #{country}" do
        setup do
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an outcome where residency is in the ceremony country and the partner is the opposite sex" do
          add_responses legal_residency?: "ceremony_country",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country and the partner is the same sex" do
          add_responses legal_residency?: "ceremony_country",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country and the partner is the opposite sex" do
          add_responses legal_residency?: "third_country",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country and the partner is the same sex" do
          add_responses legal_residency?: "third_country",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is the opposite sex" do
          add_responses legal_residency?: "uk",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is the same sex" do
          add_responses legal_residency?: "uk",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end
      end
    end

    FOUR_QUESTION_COUNTRIES.each do |country|
      context "Four question country: #{country}" do
        setup do
          # stubbing a single country at a time makes this test > 60s faster
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is British and opposite sex" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is British and same sex" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is local and opposite sex" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is local and same sex" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is not local and opposite sex" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is not local and same sex" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is British and opposite sex" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is British and same sex" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is local and opposite sex" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is local and same sex" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is not local and opposite sex" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is not local and same sex" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is British and opposite sex" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is British and same sex" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is local and opposite sex" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is local and same sex" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is not local and opposite sex" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is not local and same sex" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end
      end
    end
  end

  def stub_worldwide_api(country_slugs)
    stub_worldwide_api_has_locations(country_slugs)

    WORLDWIDE_ORGANISATION_API_COUNTRIES.intersection(country_slugs).each do |slug|
      stub_worldwide_api_has_organisations_for_location(slug, { results: [] })
    end
  end
end
