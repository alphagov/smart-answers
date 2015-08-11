# Abbreviations used in this smart answer:
# CNI - Certificate of No Impediment
# CI - Channel Islands
# CP - Civil Partnership
# FCO - Foreign & Commonwealth Office
# IOM - Isle Of Man
# OS - Opposite Sex
# SS - Same Sex

module SmartAnswer
  class MarriageAbroadFlow < Flow
    def define
      name 'marriage-abroad'
      status :published
      satisfies_need "101000"

      data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
      country_name_query = SmartAnswer::Calculators::CountryNameFormatter.new
      reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
      exclude_countries = %w(holy-see british-antarctic-territory the-occupied-palestinian-territories)

      # Q1
      country_select :country_of_ceremony?, exclude_countries: exclude_countries do
        save_input_as :ceremony_country

        calculate :location do
          loc = WorldLocation.find(ceremony_country)
          raise InvalidResponse unless loc
          loc
        end
        calculate :organisation do
          location.fco_organisation
        end
        calculate :overseas_passports_embassies do
          if organisation
            organisation.offices_with_service 'Registrations of Marriage and Civil Partnerships'
          else
            []
          end
        end

        calculate :marriage_and_partnership_phrases do
          if data_query.ss_marriage_countries?(ceremony_country) || data_query.ss_marriage_countries_when_couple_british?(ceremony_country)
            "ss_marriage"
          elsif data_query.ss_marriage_and_partnership?(ceremony_country)
            "ss_marriage_and_partnership"
          end
        end

        calculate :ceremony_country_name do
          location.name
        end

        calculate :country_name_lowercase_prefix do
          if country_name_query.class::COUNTRIES_WITH_DEFINITIVE_ARTICLES.include?(ceremony_country)
            country_name_query.definitive_article(ceremony_country)
          elsif country_name_query.class::FRIENDLY_COUNTRY_NAME.has_key?(ceremony_country)
            country_name_query.class::FRIENDLY_COUNTRY_NAME[ceremony_country].html_safe
          else
            ceremony_country_name
          end
        end

        calculate :country_name_uppercase_prefix do
          country_name_query.definitive_article(ceremony_country, true)
        end

        calculate :country_name_partner_residence do
          if data_query.british_overseas_territories?(ceremony_country)
            "British (overseas territories citizen)"
          elsif data_query.french_overseas_territories?(ceremony_country)
            "French"
          elsif data_query.dutch_caribbean_islands?(ceremony_country)
            "Dutch"
          elsif %w(hong-kong macao).include?(ceremony_country)
            "Chinese"
          else
            "National of #{country_name_lowercase_prefix}"
          end
        end

        calculate :embassy_or_consulate_ceremony_country do
          if reg_data_query.has_consulate?(ceremony_country) || reg_data_query.has_consulate_general?(ceremony_country)
            "consulate"
          else
            "embassy"
          end
        end

        next_node_if(:partner_opposite_or_same_sex?, responded_with('ireland'))
        next_node_if(:marriage_or_pacs?, responded_with(%w(france monaco new-caledonia wallis-and-futuna)))
        next_node_if(:outcome_os_france_or_fot, ->(response) { data_query.french_overseas_territories?(response)})
        next_node(:legal_residency?)
      end

      # Q2
      multiple_choice :legal_residency? do
        option :uk
        option :ceremony_country
        option :third_country

        save_input_as :resident_of

        next_node_if(:partner_opposite_or_same_sex?, variable_matches(:ceremony_country, 'switzerland'))
        next_node(:what_is_your_partners_nationality?)
      end

      # Q3a
      multiple_choice :marriage_or_pacs? do
        option :marriage
        option :pacs
        save_input_as :marriage_or_pacs

        next_node_if(:outcome_monaco, variable_matches(:ceremony_country, "monaco"))
        next_node_if(:outcome_os_france_or_fot, responded_with('marriage'))
        next_node(:outcome_cp_france_pacs)
      end

      # Q4
      multiple_choice :what_is_your_partners_nationality? do
        option :partner_british
        option :partner_local
        option :partner_other

        save_input_as :partner_nationality
        next_node :partner_opposite_or_same_sex?
      end

      # Q5
      multiple_choice :partner_opposite_or_same_sex? do
        option :opposite_sex
        option :same_sex

        save_input_as :sex_of_your_partner

        calculate :ceremony_type do |response|
          if response == 'opposite_sex'
            PhraseList.new(:ceremony_type_marriage)
          else
            PhraseList.new(:ceremony_type_civil_partnership)
          end
        end

        calculate :ceremony_type_lowercase do |response|
          if response == 'opposite_sex'
            "marriage"
          else
            "civil partnership"
          end
        end

        calculate :contact_method_key do |response|
          appointment_link_key = data_query.appointment_link_key_for(ceremony_country, response)
          appointment_link_key || :embassies_data
        end

        define_predicate(:ceremony_in_laos_partners_not_local) {
          (ceremony_country == "laos") && (partner_nationality != "partner_local")
        }

        define_predicate(:ceremony_in_finland_uk_resident) {
          (ceremony_country == "finland") && (resident_of == "uk")
        }

        define_predicate(:ceremony_in_norway_uk_resident) {
          (ceremony_country == "norway") && (resident_of == "uk")
        }

        define_predicate(:ceremony_in_brazil_not_resident_in_the_uk) {
          (ceremony_country == 'brazil') && (resident_of != 'uk')
        }

        define_predicate(:os_marriage_with_local_in_japan) {
          ceremony_country == 'japan' && resident_of == 'ceremony_country' && partner_nationality == 'partner_local'
        }

        define_predicate(:consular_cni_residing_in_third_country) {
          resident_of == 'third_country' && (data_query.os_consular_cni_countries?(ceremony_country) || %w(kosovo).include?(ceremony_country) || data_query.os_consular_cni_in_nearby_country?(ceremony_country))
        }

        define_predicate(:marriage_in_norway_third_country) {
          ceremony_country == 'norway' && resident_of == 'third_country'
        }

        next_node_if(:outcome_brazil_not_living_in_the_uk, ceremony_in_brazil_not_resident_in_the_uk)
        next_node_if(:outcome_netherlands, variable_matches(:ceremony_country, "netherlands"))
        next_node_if(:outcome_portugal, variable_matches(:ceremony_country, "portugal"))
        next_node_if(:outcome_ireland, variable_matches(:ceremony_country, "ireland"))
        next_node_if(:outcome_switzerland, variable_matches(:ceremony_country, "switzerland"))
        next_node_if(:outcome_spain, variable_matches(:ceremony_country, "spain"))

        on_condition(responded_with('opposite_sex')) do
          next_node_if(:outcome_os_hong_kong, variable_matches(:ceremony_country, 'hong-kong'))
          next_node_if(:outcome_consular_cni_os_residing_in_third_country, consular_cni_residing_in_third_country)
          next_node_if(:outcome_consular_cni_os_residing_in_third_country, marriage_in_norway_third_country)
          next_node_if(:outcome_os_local_japan, os_marriage_with_local_in_japan)
          next_node_if(:outcome_os_colombia, variable_matches(:ceremony_country, "colombia"))
          next_node_if(:outcome_os_kosovo, variable_matches(:ceremony_country, "kosovo"))
          next_node_if(:outcome_os_indonesia, variable_matches(:ceremony_country, "indonesia"))
          next_node_if(:outcome_os_marriage_impossible_no_laos_locals, ceremony_in_laos_partners_not_local)
          next_node_if(:outcome_os_laos, variable_matches(:ceremony_country, "laos"))
          next_node_if(:outcome_os_consular_cni, -> {
            data_query.os_consular_cni_countries?(ceremony_country) || (resident_of == 'uk' && data_query.os_no_marriage_related_consular_services?(ceremony_country)) || data_query.os_consular_cni_in_nearby_country?(ceremony_country)
          })
          next_node_if(:outcome_os_consular_cni, ceremony_in_finland_uk_resident)
          next_node_if(:outcome_os_consular_cni, ceremony_in_norway_uk_resident)
          next_node_if(:outcome_os_affirmation, -> { data_query.os_affirmation_countries?(ceremony_country) })
          next_node_if(:outcome_os_commonwealth, -> { data_query.commonwealth_country?(ceremony_country) || ceremony_country == 'zimbabwe' })
          next_node_if(:outcome_os_bot, -> { data_query.british_overseas_territories?(ceremony_country) })
          next_node_if(:outcome_os_no_cni, -> {
            data_query.os_no_consular_cni_countries?(ceremony_country) || (resident_of != 'uk' && data_query.os_no_marriage_related_consular_services?(ceremony_country))
          })
          next_node_if(:outcome_os_other_countries, -> {
            data_query.os_other_countries?(ceremony_country)
          })
        end

        on_condition(responded_with('same_sex')) do
          define_predicate(:ss_marriage_germany_partner_local?) {
            (ceremony_country == "germany") && (partner_nationality == "partner_local") && (ceremony_type != 'opposite_sex')
          }
          define_predicate(:ss_marriage_countries?) {
            data_query.ss_marriage_countries?(ceremony_country)
          }
          define_predicate(:ss_marriage_countries_when_couple_british?) {
            data_query.ss_marriage_countries_when_couple_british?(ceremony_country) && %w(partner_british).include?(partner_nationality)
          }
          define_predicate(:ss_marriage_and_partnership?) {
            data_query.ss_marriage_and_partnership?(ceremony_country)
          }

          define_predicate(:ss_marriage_not_possible?) {
            data_query.ss_marriage_not_possible?(ceremony_country, partner_nationality)
          }

          define_predicate(:ss_unknown_no_embassies) {
            data_query.ss_unknown_no_embassies?(ceremony_country)
          }

          define_predicate(:ss_affirmation) {
            %w(belgium norway).include?(ceremony_country)
          }

          next_node_if(:outcome_ss_affirmation, ss_affirmation)

          next_node_if(:outcome_os_no_cni, ss_unknown_no_embassies)

          next_node_if(:outcome_ss_marriage_malta, -> {ceremony_country == "malta"})

          next_node_if(:outcome_ss_marriage_not_possible, ss_marriage_not_possible?)

          next_node_if(:outcome_cp_or_equivalent, ss_marriage_germany_partner_local?)

          next_node_if(:outcome_ss_marriage,
            ss_marriage_countries? | ss_marriage_countries_when_couple_british? | ss_marriage_and_partnership?
          )

          next_node_if(:outcome_cp_or_equivalent, -> {
            data_query.cp_equivalent_countries?(ceremony_country)
          })

          next_node_if(:outcome_cp_no_cni, -> {
            data_query.cp_cni_not_required_countries?(ceremony_country)
          })

          next_node_if(:outcome_cp_commonwealth_countries, -> {
            %w(canada south-africa).include?(ceremony_country)
          })

          next_node_if(:outcome_cp_consular, -> {
            data_query.cp_consular_countries?(ceremony_country)
          })

          next_node(:outcome_cp_all_other_countries)
        end
      end

      outcome :outcome_ireland, use_outcome_templates: true

      outcome :outcome_switzerland, use_outcome_templates: true

      outcome :outcome_netherlands, use_outcome_templates: true

      outcome :outcome_portugal, use_outcome_templates: true

      outcome :outcome_os_indonesia, use_outcome_templates: true

      outcome :outcome_os_laos, use_outcome_templates: true

      outcome :outcome_os_local_japan, use_outcome_templates: true

      outcome :outcome_os_hong_kong, use_outcome_templates: true

      outcome :outcome_os_kosovo, use_outcome_templates: true

      outcome :outcome_brazil_not_living_in_the_uk, use_outcome_templates: true

      outcome :outcome_os_colombia, use_outcome_templates: true

      outcome :outcome_monaco, use_outcome_templates: true

      outcome :outcome_spain do
        precalculate :ceremony_type do
          if sex_of_your_partner == 'opposite_sex'
            PhraseList.new(:ceremony_type_marriage)
          else
            PhraseList.new(:ceremony_type_ss_marriage)
          end
        end

        precalculate :current_path do
          (['/marriage-abroad/y'] + responses).join('/')
        end

        precalculate :uk_residence_outcome_path do
          current_path.gsub('third_country', 'uk')
        end

        precalculate :ceremony_country_residence_outcome_path do
          current_path.gsub('third_country', 'ceremony_country')
        end

        precalculate :body do
          phrases = PhraseList.new
          if resident_of != 'uk'
            phrases << :contact_local_authorities_in_country_marriage
          end

          if resident_of != 'third_country' && sex_of_your_partner == 'opposite_sex'
            phrases << :civil_weddings_in_spain
          end

          if sex_of_your_partner == 'same_sex'
            phrases << :ss_process_in_spain
          end

          if resident_of == 'ceremony_country'
            phrases << :get_legal_advice
          else
            phrases << :get_legal_and_travel_advice
            phrases << :legal_restrictions_for_non_residents_spain
          end

          phrases << :what_you_need_to_do
          phrases << :cni_maritial_status_certificate_spain
          if resident_of == 'third_country'
            phrases << :what_you_need_to_do_spain_third_country
          else
            phrases << :what_you_need_to_do_spain
          end

          if resident_of == 'uk'
            phrases << :get_cni_in_uk_for_spain_title
            phrases << :cni_at_local_register_office
            phrases << :get_cni_in_uk_for_spain
          elsif resident_of == 'ceremony_country'
            phrases << :get_cni_in_spain
          end

          if resident_of != 'third_country'
            phrases << :get_maritial_status_certificate_spain

            if resident_of == 'ceremony_country'
              phrases << :other_requirements_in_spain_for_residents_intro
            else
              phrases << :other_requirements_in_spain_intro
            end
            phrases << :other_requirements_in_spain

            phrases << :names_on_documents_must_match

            unless partner_nationality == 'partner_british'
              phrases << :partner_naturalisation_in_uk
            end

            phrases << :consular_cni_os_fees_incl_null_osta_oath_consular_letter
            phrases << :link_to_consular_fees
            phrases << :pay_by_visas_or_mastercard
          end
          phrases
        end
      end

      outcome :outcome_os_commonwealth, use_outcome_templates: true

      outcome :outcome_os_bot, use_outcome_templates: true

      outcome :outcome_consular_cni_os_residing_in_third_country, use_outcome_templates: true do
        precalculate :data_query do
          data_query
        end

        precalculate :current_path do
          (['/marriage-abroad/y'] + responses).join('/')
        end

        precalculate :uk_residence_outcome_path do
          current_path.gsub('third_country', 'uk')
        end

        precalculate :ceremony_country_residence_outcome_path do
          current_path.gsub('third_country', 'ceremony_country')
        end
      end

      outcome :outcome_os_consular_cni, use_outcome_templates: true do
        precalculate :data_query do
          data_query
        end
        precalculate :three_day_residency_requirement_applies do
          %w(albania algeria angola armenia austria azerbaijan bahrain belarus bolivia bosnia-and-herzegovina bulgaria chile croatia cuba democratic-republic-of-congo denmark dominican-republic el-salvador estonia ethiopia georgia greece guatemala honduras hungary iceland italy kazakhstan kosovo kuwait kyrgyzstan latvia lithuania luxembourg macedonia mexico moldova montenegro nepal panama poland romania russia serbia slovenia sudan sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
        end
        precalculate :three_day_residency_handled_by_exception do
          %w(croatia italy russia)
        end
        precalculate :no_birth_cert_requirement do
          three_day_residency_requirement_applies - ['italy']
        end
        precalculate :cni_notary_public_countries do
          %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland kazakhstan kuwait kyrgyzstan libya lithuania luxembourg mexico moldova montenegro poland russia serbia sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
        end
        precalculate :no_document_download_link_if_os_resident_of_uk_countries do
          %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland italy japan kazakhstan kuwait kyrgyzstan libya lithuania luxembourg macedonia mexico moldova montenegro nicaragua poland russia serbia sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
        end
        precalculate :cni_posted_after_14_days_countries do
          %w(oman jordan qatar saudi-arabia united-arab-emirates yemen)
        end
        precalculate :ceremony_not_germany_or_not_resident_other do
          # TODO verify this is ok
          (ceremony_country != 'germany' || resident_of == 'uk')
        end
        precalculate :ceremony_and_residency_in_croatia do
          (ceremony_country == 'croatia' && resident_of == 'ceremony_country')
        end
        precalculate :birth_cert_inclusion do
          if no_birth_cert_requirement.exclude?(ceremony_country)
            '_incl_birth_cert'
          end
        end
        precalculate :notary_public_inclusion do
          if cni_notary_public_countries.include?(ceremony_country) || %w(japan macedonia).include?(ceremony_country)
            '_notary_public'
          end
        end
      end

      outcome :outcome_os_france_or_fot, use_outcome_templates: true do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_os_affirmation, use_outcome_templates: true do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_os_no_cni, use_outcome_templates: true do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_os_other_countries, use_outcome_templates: true

      #CP outcomes
      outcome :outcome_cp_or_equivalent, use_outcome_templates: true do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_cp_france_pacs do
        precalculate :france_pacs_law_cp_outcome do
          PhraseList.new(:fot_cp_all) if %w(new-caledonia wallis-and-futuna).include?(ceremony_country)
        end
      end

      outcome :outcome_cp_no_cni do
        precalculate :no_cni_required_cp_outcome do
          phrases = PhraseList.new
          phrases << :"synonyms_of_cp_in_#{ceremony_country}" if data_query.cp_cni_not_required_countries?(ceremony_country)

          if resident_of == 'ceremony_country'
            phrases << :get_legal_advice
          else
            phrases << :get_legal_and_travel_advice
          end

          phrases << :what_you_need_to_do
          if ceremony_country == 'bonaire-st-eustatius-saba'
            phrases << :country_is_dutch_caribbean_island
            if resident_of == 'uk'
              phrases << :contact_dutch_embassy_in_uk_cp
            else
              phrases << :contact_local_authorities_in_country_cp
            end
          else
            if resident_of == 'uk'
              phrases << :contact_embassy_or_consulate_representing_ceremony_country_in_uk_cp
            else
              phrases << :contact_local_authorities_in_country_cp
            end
          end
          phrases << :no_consular_facilities_to_register_ss
          if partner_nationality != 'partner_british'
            phrases << :partner_naturalisation_in_uk
          end
          phrases
        end
      end

      outcome :outcome_cp_commonwealth_countries do
        precalculate :type_of_ceremony do
          phrases = PhraseList.new(:title_civil_partnership)
        end

        precalculate :commonwealth_countries_cp_outcome do
          phrases = PhraseList.new
          phrases << :"synonyms_of_cp_in_#{ceremony_country}"

          if resident_of == 'uk'
            phrases << :contact_high_comission_of_ceremony_country_in_uk_cp
          else
            phrases << :contact_local_authorities_in_country_cp
          end

          if resident_of == 'ceremony_country'
            phrases << :get_legal_advice
          else
            phrases << :get_legal_and_travel_advice
          end

          phrases << contact_method_key

          if partner_nationality != 'partner_british'
            phrases << :partner_naturalisation_in_uk
          end
          phrases
        end
      end

      outcome :outcome_cp_consular do
        precalculate :institution_name do
          if ceremony_country == 'cyprus'
            "High Commission"
          else
            "British embassy or consulate"
          end
        end

        precalculate :consular_cp_outcome do
          phrases = PhraseList.new(:cp_may_be_possible)

          if %w(croatia bulgaria).include?(ceremony_country) && partner_nationality == 'partner_local'
            phrases << :cant_register_cp_with_country_national
          else
            phrases << :contact_to_make_appointment
          end
          phrases << contact_method_key

          phrases << :documents_needed_7_days_residency

          phrases << :documents_for_both_partners_cp
          if partner_nationality != 'partner_british'
            phrases << :additional_non_british_partner_documents_cp
          end

          phrases << :consular_cp_what_you_need_to_do

          unless partner_nationality == 'partner_british'
            phrases << :partner_naturalisation_in_uk
          end

          phrases << :consular_cp_standard_fees
          phrases << :pay_by_cash_or_credit_card_no_cheque
          phrases
        end
      end

      outcome :outcome_cp_all_other_countries

      outcome :outcome_ss_marriage do
        precalculate :ss_title do
          PhraseList.new(:"title_#{marriage_and_partnership_phrases}")
        end

        precalculate :ss_fees_table do
          if data_query.ss_alt_fees_table_country?(ceremony_country, partner_nationality)
            :"#{marriage_and_partnership_phrases}_alt"
          else
            :"#{marriage_and_partnership_phrases}"
          end
        end

        precalculate :ss_ceremony_body do
          phrases = PhraseList.new
          phrases << :"able_to_#{marriage_and_partnership_phrases}"

          if ceremony_country == 'japan'
            phrases << :contact_to_make_appointment << contact_method_key << :documents_needed_21_days_residency << :documents_needed_ss_british
          elsif ceremony_country == 'germany'
            phrases << :contact_british_embassy_or_consulate_berlin << contact_method_key
          else
            if contact_method_key == :embassies_data
              phrases << :contact_embassy_or_consulate
            end
            phrases << contact_method_key
          end

          unless ceremony_country == 'japan'
            phrases << :documents_needed_21_days_residency

            if partner_nationality == 'partner_british'
              phrases << :documents_needed_ss_british
            elsif ceremony_country == 'germany'
              phrases << :documents_needed_ss_not_british_germany_same_sex
            else
              phrases << :documents_needed_ss_not_british
            end
          end
          phrases << :"what_to_do_#{marriage_and_partnership_phrases}" << :will_display_in_14_days << :"no_objection_in_14_days_#{marriage_and_partnership_phrases}" << :"provide_two_witnesses_#{marriage_and_partnership_phrases}"
          if ceremony_country == 'australia'
            phrases << :australia_ss_relationships
          end

          phrases << :ss_marriage_footnote
          phrases << :partner_naturalisation_in_uk << :"fees_table_#{ss_fees_table}"

          if ceremony_country == 'cambodia'
            phrases << :pay_by_cash_or_us_dollars_only
          else
            phrases << :link_to_consular_fees << :pay_by_cash_or_credit_card_no_cheque
          end

          if %w{albania australia germany japan philippines russia serbia vietnam}.include?(ceremony_country)
            phrases << :convert_cc_to_ss_marriage
          end
          phrases
        end
      end

      outcome :outcome_ss_marriage_not_possible

      outcome :outcome_ss_marriage_malta do
        precalculate :ss_body do
          PhraseList.new(:able_to_ss_marriage_and_partnership_hc, :contact_to_make_appointment, contact_method_key, :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage_and_partnership_hc, :will_display_in_14_days_hc, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote_hc, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :convert_cc_to_ss_marriage)
        end
      end

      outcome :outcome_ss_affirmation do
        precalculate :body do
          phrases = PhraseList.new
          phrases << :"synonyms_of_cp_in_#{ceremony_country}"

          if resident_of == 'uk'
            phrases << :contact_embassy_of_ceremony_country_in_uk_cp
          else
            phrases << :contact_local_authorities_in_country_cp
          end

          if resident_of == 'ceremony_country'
            phrases << :get_legal_advice
          else
            phrases << :get_legal_and_travel_advice
          end

          phrases << :what_you_need_to_do_affirmation

          if ceremony_country == 'norway'
            phrases << :appointment_for_affidavit_norway
          else
            phrases << :appointment_for_affidavit
          end

          phrases << contact_method_key

          if ceremony_country == 'belgium'
            phrases << :complete_affirmation_or_affidavit_forms
            phrases << :download_and_fill_but_not_sign
            phrases << :download_affidavit_and_affirmation_belgium
          end

          phrases << :partner_needs_affirmation

          if ceremony_country == 'belgium'
            phrases << :required_supporting_documents
            phrases << :documents_guidance_belgium
          end

          phrases << :legalisation_and_translation
          phrases << :affirmation_os_translation_in_local_language_text
          phrases << :divorce_proof_cp

          if ceremony_country == 'belgium'
            phrases << :names_on_documents_must_match
          end

          if partner_nationality == 'partner_british'
            phrases << :partner_probably_needs_affirmation
          else
            phrases << :callout_partner_equivalent_document
            phrases << :partner_naturalisation_in_uk
          end

          phrases << :fee_table_affirmation_55
          phrases << :link_to_consular_fees

          if ceremony_country == 'norway'
            phrases << :pay_by_visas_or_mastercard
          else
            phrases << :pay_by_cash_or_credit_card_no_cheque
          end
        end
      end

      outcome :outcome_os_marriage_impossible_no_laos_locals
    end
  end
end
