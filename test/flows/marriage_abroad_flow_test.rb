require "test_helper"
require "support/flow_test_helper"

class MarriageAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  delegate :countries_list, to: :class

  # These countries use the worldwide organisation API and need an extra stub
  WORLDWIDE_ORGANISATION_API_COUNTRIES = %w[sweden].freeze

  def self.countries_list(type)
    @countries ||= YAML.load_file(Rails.root.join("config/smart_answers/marriage_abroad_data.yml"))
    list = @countries.fetch(type.to_s)
    raise "Expected some countries for #{type}" unless list.any?

    list
  end

  def stub_worldwide_api(country_slugs)
    stub_worldwide_api_has_locations(country_slugs)

    WORLDWIDE_ORGANISATION_API_COUNTRIES.intersection(country_slugs).each do |slug|
      stub_worldwide_api_has_organisations_for_location(slug, { results: [] })
    end
  end

  def all_countries_list
    all_types = %w[countries_with_ceremony_location_outcomes
                   countries_with_19_outcomes
                   countries_with_2_outcomes_marriage_or_pacs
                   countries_with_3_outcomes
                   countries_with_1_outcome
                   countries_with_2_outcomes
                   countries_with_6_outcomes
                   countries_with_9_outcomes
                   countries_with_18_outcomes]
    all_types.sum([]) { |t| countries_list(t) }
  end

  def random_country(type = nil)
    type ? countries_list(type).sample : all_countries_list.sample
  end

  setup { testing_flow MarriageAbroadFlow }

  should "render start page" do
    assert_rendered_start_page
  end

  context "question: country_of_ceremony?" do
    setup do
      testing_node :country_of_ceremony?
      stub_worldwide_api(all_countries_list)
    end

    should "render question" do
      assert_rendered_question
    end

    context "validations" do
      should "be invalid for a country that doesn't exist" do
        assert_invalid_response "non-existent-country"
      end

      should "be valid for a country that exists" do
        assert_valid_response random_country
      end
    end

    context "next_node" do
      should "have a next_node of partner_opposite_or_same_sex? for a two outcome country" do
        assert_next_node :partner_opposite_or_same_sex?, for_response: random_country(:countries_with_2_outcomes)
      end

      should "have a next_node of partner_opposite_or_same_sex? for hungary" do
        assert_next_node :partner_opposite_or_same_sex?, for_response: "hungary"
      end

      should "have a next_node of marriage_or_pacs? for a marriage or pacs country" do
        assert_next_node :marriage_or_pacs?, for_response: random_country(:countries_with_2_outcomes_marriage_or_pacs)
      end

      should "have a next_node of outcome_marriage_abroad_in_country for a 1 outcome country" do
        assert_next_node :outcome_marriage_abroad_in_country, for_response: random_country(:countries_with_1_outcome)
      end

      should "have a next_node of legal_residency? for other countries" do
        country_list = countries_list(:countries_with_6_outcomes).clone
        country_list.delete("hungary")
        assert_next_node :legal_residency?, for_response: country_list.sample
      end
    end
  end

  context "question: legal_residency?" do
    context "hungary" do
      setup do
        testing_node :legal_residency?
        stub_worldwide_api(all_countries_list)
        add_responses country_of_ceremony?: "hungary", partner_opposite_or_same_sex?: "opposite_sex"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next_node of outcome_marriage_abroad_in_country" do
          assert_next_node :outcome_marriage_abroad_in_country, for_response: "uk"
        end
      end
    end

    context "not hungary" do
      setup do
        testing_node :legal_residency?
        stub_worldwide_api(all_countries_list)
        add_responses country_of_ceremony?: random_country(:countries_with_18_outcomes)
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next_node of outcome_marriage_abroad_in_country for a ceremony location country" do
          add_responses country_of_ceremony?: random_country(:countries_with_ceremony_location_outcomes)
          assert_next_node :outcome_marriage_abroad_in_country, for_response: "uk"
        end

        should "have a next_node of partner_opposite_or_same_sex? for a 6 outcome country (except hungary)" do
          country_list = countries_list(:countries_with_6_outcomes).clone
          country_list.delete("hungary")
          add_responses country_of_ceremony?: country_list.sample
          assert_next_node :partner_opposite_or_same_sex?, for_response: "uk"
        end

        should "have a next_node of what_is_your_partners_nationality? for other countries" do
          assert_next_node :what_is_your_partners_nationality?, for_response: "uk"
        end
      end
    end
  end

  context "question: marriage_or_pacs?" do
    setup do
      testing_node :marriage_or_pacs?
      stub_worldwide_api(all_countries_list)
      add_responses country_of_ceremony?: random_country(:countries_with_2_outcomes_marriage_or_pacs)
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
      stub_worldwide_api(all_countries_list)
      add_responses country_of_ceremony?: random_country(:countries_with_18_outcomes),
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
    context "hungary" do
      setup do
        testing_node :partner_opposite_or_same_sex?
        stub_worldwide_api(all_countries_list)
        add_responses country_of_ceremony?: "hungary"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next_node of legal_residency? for hungary" do
          assert_next_node :legal_residency?, for_response: "opposite_sex"
        end
      end
    end

    context "not hungary" do
      setup do
        testing_node :partner_opposite_or_same_sex?
        stub_worldwide_api(all_countries_list)
        add_responses country_of_ceremony?: random_country(:countries_with_18_outcomes),
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
  end

  context "question: marriage_or_civil_partnership?" do
    setup do
      testing_node :marriage_or_civil_partnership?
      stub_worldwide_api(all_countries_list)
      add_responses country_of_ceremony?: random_country(:countries_with_3_outcomes),
                    partner_opposite_or_same_sex?: "opposite_sex"
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

  context "outcome :outcome_marriage_abroad_in_country" do
    setup { testing_node :outcome_marriage_abroad_in_country }

    countries_list(:countries_with_2_outcomes_marriage_or_pacs).each do |country|
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

    countries_list(:countries_with_ceremony_location_outcomes).each do |country|
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

    countries_list(:countries_with_1_outcome).each do |country|
      context "1 outcome country #{country}" do
        setup do
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an outcome" do
          assert_rendered_outcome
        end
      end
    end

    countries_list(:countries_with_2_outcomes).each do |country|
      context "2 outcome country: #{country}" do
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

    countries_list(:countries_with_3_outcomes).each do |country|
      context "2 outcome country offering consular civil partnership: #{country}" do
        setup do
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an opposite sex civil partnership outcome" do
          add_responses partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
          assert_rendered_outcome
        end

        should "render an opposite sex civil marriage outcome" do
          add_responses partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render a same sex outcome" do
          add_responses partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end
      end
    end

    countries_list(:countries_with_6_outcomes).each do |country|
      context "6 outcome country: #{country}" do
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

    countries_list(:countries_with_18_outcomes).each do |country|
      context "18 outcome country: #{country}" do
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

    countries_list(:countries_with_9_outcomes).each do |country|
      context "9 outcome country: #{country}" do
        setup do
          # stubbing a single country at a time makes this test > 60s faster
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is British" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_british"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is local" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_local"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is not local" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_other"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is British" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_british"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is local" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_local"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is not local" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_other"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is British" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_british"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is local" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_local"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is not local" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_other"
          assert_rendered_outcome
        end
      end
    end

    countries_list(:countries_with_19_outcomes).each do |country|
      context "18 outcome country offering consular civil partnerships: #{country}" do
        setup do
          # stubbing a single country at a time makes this test > 60s faster
          stub_worldwide_api([country])
          add_responses country_of_ceremony?: country
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is British and opposite sex getting married" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is British and opposite sex registering a civil partnership" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
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
               "and the partner is local and opposite sex getting married" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is local and opposite sex registering a " \
               " civil partnership" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
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
               "and the partner is not local and opposite sex getting married" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the ceremony country " \
               "and the partner is not local and opposite sex registering a civil partnership" do
          add_responses legal_residency?: "ceremony_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
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
               "and the partner is British and opposite sex getting married" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is British and opposite sex registering a " \
               "civil partnership" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
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
               "and the partner is local and opposite sex getting married" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is local and opposite sex registering a civil partnership" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
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
               "and the partner is not local and opposite sex getting married" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is not local and opposite sex registering a " \
               "civil partnership" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in a different country " \
               "and the partner is not local and same sex" do
          add_responses legal_residency?: "third_country",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner " \
                "is British and opposite sex getting married" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner " \
               "is British and opposite sex registering a civil partnership" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is British and same sex" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_british",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner "\
               "is local and opposite sex getting married" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner " \
               " is local and opposite sex registering a civil partnership" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner is local and same sex" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_local",
                        partner_opposite_or_same_sex?: "same_sex"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner " \
               " is not local and opposite sex getting married" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "marriage"
          assert_rendered_outcome
        end

        should "render an outcome where residency is in the UK and the partner " \
               " is not local and opposite sex registering a civil partnership" do
          add_responses legal_residency?: "uk",
                        what_is_your_partners_nationality?: "partner_other",
                        partner_opposite_or_same_sex?: "opposite_sex",
                        marriage_or_civil_partnership?: "civil_partnership"
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
end
