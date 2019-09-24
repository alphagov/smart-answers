require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/marriage-abroad"

class MarriageAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  FLATTEN_COUNTRIES_CEREMONY_LOCATION_OUTCOMES = %w(finland iceland).freeze
  FLATTEN_COUNTRIES_1_OUTCOME = %w(french-guiana french-polynesia guadeloupe martinique mayotte reunion st-pierre-and-miquelon).freeze
  FLATTEN_COUNTRIES_2_OUTCOMES = %w(australia china croatia cyprus egypt france india ireland japan luxembourg philippines south-africa south-korea south-korea thailand turkey usa zimbabwe).freeze
  FLATTEN_COUNTRIES_2_OUTCOMES_MARRIAGE_OR_PACS = %w(monaco new-caledonia wallis-and-futuna).freeze
  FLATTEN_COUNTRIES_6_OUTCOMES = %w(greece italy poland spain switzerland).freeze
  FLATTEN_COUNTRIES_18_OUTCOMES = %w(afghanistan albania algeria american-samoa andorra angola anguilla antigua-and-barbuda argentina armenia aruba austria azerbaijan bahamas bahrain bangladesh barbados belarus belgium belize benin bermuda bhutan bolivia bonaire-st-eustatius-saba bosnia-and-herzegovina botswana brazil british-indian-ocean-territory british-virgin-islands brunei bulgaria burkina-faso burundi cambodia cameroon canada cape-verde cayman-islands central-african-republic chad chile colombia comoros costa-rica cote-d-ivoire cuba curacao czech-republic democratic-republic-of-the-congo denmark djibouti dominica dominican-republic ecuador el-salvador equatorial-guinea eritrea estonia eswatini ethiopia falkland-islands fiji gabon georgia germany ghana gibraltar grenada guatemala guinea guinea-bissau guyana haiti honduras hong-kong hungary indonesia iran iraq israel jamaica jordan kazakhstan kenya kiribati kosovo kuwait kyrgyzstan laos latvia lebanon lesotho liberia libya liechtenstein lithuania macao madagascar malawi malaysia maldives malta marshall-islands mauritania mauritius mexico micronesia moldova mongolia montenegro montserrat morocco mozambique myanmar namibia nauru nepal netherlands new-zealand nicaragua niger nigeria north-korea north-macedonia norway oman pakistan palau panama papua-new-guinea paraguay peru pitcairn-island portugal qatar romania russia rwanda saint-barthelemy san-marino sao-tome-and-principe saudi-arabia senegal serbia seychelles sierra-leone singapore slovakia slovenia solomon-islands somalia south-georgia-and-the-south-sandwich-islands south-sudan sri-lanka st-helena-ascension-and-tristan-da-cunha st-kitts-and-nevis st-lucia st-maarten st-martin st-vincent-and-the-grenadines sudan suriname sweden syria taiwan tajikistan tanzania the-gambia timor-leste togo tonga trinidad-and-tobago tunisia turkmenistan turks-and-caicos-islands tuvalu uganda ukraine united-arab-emirates uruguay uzbekistan vanuatu venezuela vietnam western-sahara yemen zambia).freeze
  FLATTEN_COUNTRIES = FLATTEN_COUNTRIES_CEREMONY_LOCATION_OUTCOMES + FLATTEN_COUNTRIES_1_OUTCOME + FLATTEN_COUNTRIES_2_OUTCOMES + FLATTEN_COUNTRIES_2_OUTCOMES_MARRIAGE_OR_PACS + FLATTEN_COUNTRIES_6_OUTCOMES + FLATTEN_COUNTRIES_18_OUTCOMES

  def self.translations
    @translations ||= YAML.load_file("lib/smart_answer_flows/locales/en/marriage-abroad.yml")
  end

  setup do
    @location_slugs = FLATTEN_COUNTRIES
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::MarriageAbroadFlow
  end

  should "which country you want the ceremony to take place in" do
    assert_current_node :country_of_ceremony?
  end

  context "newly added country that has no logic to handle opposite sex marriages" do
    setup do
      stub_world_locations(%w[narnia])
      add_response "ceremony_country"
      add_response "partner_local"
      assert_raises(SmartAnswer::Question::Base::NextNodeUndefined) do
        add_response "opposite_sex"
      end
    end
  end

  context "ceremony is outside ireland" do
    setup do
      add_response "bahamas"
    end
    should "ask your country of residence" do
      assert_current_node :legal_residency?
      assert_equal "Bahamas", current_state.calculator.ceremony_country_name
      assert_equal "the Bahamas", current_state.calculator.country_name_lowercase_prefix
    end

    context "resident in UK" do
      setup do
        add_response "uk"
      end

      should "go to partner nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_equal "Bahamas", current_state.calculator.ceremony_country_name
        assert_equal "the Bahamas", current_state.calculator.country_name_lowercase_prefix
      end

      context "partner is british" do
        setup do
          add_response "partner_british"
        end
        should "ask what sex is your partner" do
          assert_current_node :partner_opposite_or_same_sex?
        end
        context "opposite sex partner" do
          setup do
            add_response "opposite_sex"
          end
          should "give outcome opposite sex commonwealth" do
            expected_location = WorldLocation.find("bahamas")
            assert_equal expected_location, current_state.calculator.world_location
          end
        end
      end
    end

    context "resident in the ceremony country" do
      setup do
        add_response "ceremony_country"
      end

      should "go to partner's nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_equal "Bahamas", current_state.calculator.ceremony_country_name
      end

      context "partner is local" do
        setup do
          add_response "partner_local"
        end
        should "ask what sex is your partner" do
          assert_current_node :partner_opposite_or_same_sex?
        end
      end
    end

    context "resident in 3rd country" do
      setup do
        add_response "third_country"
      end

      should "go to partner's nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_equal "Bahamas", current_state.calculator.ceremony_country_name
      end

      context "partner is local" do
        setup do
          add_response "partner_local"
        end
        should "ask what sex is your partner" do
          assert_current_node :partner_opposite_or_same_sex?
        end
      end
    end
  end

  FLATTEN_COUNTRIES_18_OUTCOMES.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response country
      end
      context "resident in uk," do
        setup { add_response "uk" }
        context "partner is british," do
          setup { add_response "partner_british" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is local," do
          setup { add_response "partner_local" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is other," do
          setup { add_response "partner_other" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
      end
      context "resident in ceremony country" do
        setup { add_response "ceremony_country" }
        context "partner is british," do
          setup { add_response "partner_british" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is local," do
          setup { add_response "partner_local" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is other," do
          setup { add_response "partner_other" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
      end
      context "resident in third country" do
        setup { add_response "third_country" }
        context "partner is british," do
          setup { add_response "partner_british" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is local," do
          setup { add_response "partner_local" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is other," do
          setup { add_response "partner_other" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
      end
    end
  end

  FLATTEN_COUNTRIES_6_OUTCOMES.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response country
      end
      context "resident in uk," do
        setup { add_response "uk" }
        context "opposite sex" do
          setup { add_response "opposite_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
        context "same sex" do
          setup { add_response "same_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
      end
      context "resident in ceremony country" do
        setup { add_response "ceremony_country" }
        context "opposite sex" do
          setup { add_response "opposite_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
        context "same sex" do
          setup { add_response "same_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
      end
      context "resident in third country" do
        setup { add_response "third_country" }
        context "opposite sex" do
          setup { add_response "opposite_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
        context "same sex" do
          setup { add_response "same_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
      end
    end
  end

  FLATTEN_COUNTRIES_2_OUTCOMES.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response country
      end

      context "opposite sex" do
        setup { add_response "opposite_sex" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end

      context "same sex" do
        setup { add_response "same_sex" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end
    end
  end

  FLATTEN_COUNTRIES_2_OUTCOMES_MARRIAGE_OR_PACS.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response country
      end

      context "marriage" do
        setup { add_response "marriage" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end

      context "pacs" do
        setup { add_response "pacs" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end
    end
  end

  FLATTEN_COUNTRIES_1_OUTCOME.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response country
      end

      should "go to generic country outcome" do
        assert_current_node :outcome_marriage_abroad_in_country
      end
    end
  end

  FLATTEN_COUNTRIES_CEREMONY_LOCATION_OUTCOMES.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response country
      end

      context "uk" do
        setup { add_response "uk" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end

      context "ceremony country" do
        setup { add_response "ceremony_country" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end

      context "third country" do
        setup { add_response "third_country" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end
    end
  end
end
