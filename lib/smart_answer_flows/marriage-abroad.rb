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
            country_name_query.class::FRIENDLY_COUNTRY_NAME[ceremony_country]
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

      outcome :outcome_os_hong_kong

      outcome :outcome_os_kosovo do
        precalculate :kosovo_os_phraselist do
          phrases = PhraseList.new
          if resident_of == 'uk'
            phrases << :kosovo_uk_resident
          else
            phrases << :kosovo_local_resident
          end
        end
      end

      outcome :outcome_brazil_not_living_in_the_uk do
        precalculate :brazil_phraselist_not_in_the_uk do
          phrases = PhraseList.new
          if resident_of == 'ceremony_country'
            phrases << :contact_local_authorities << :get_legal_advice << :consular_cni_os_download_affidavit_notary_public << :notary_public_will_charge_a_fee << :names_on_documents_must_match << :partner_naturalisation_in_uk
          else
            phrases << :contact_local_authorities_in_country_marriage << :get_legal_and_travel_advice << :what_you_need_to_do << :make_an_appointment_bring_passport_and_pay_55_brazil << :link_to_consular_fees << :pay_by_cash_or_credit_card_no_cheque << contact_method_key << :download_affidavit_forms_but_do_not_sign << :download_affidavit_brazil << :documents_for_divorced_or_widowed
          end
          phrases
        end
      end

      outcome :outcome_os_colombia do
        precalculate :colombia_os_phraselist do
          PhraseList.new(
            :contact_embassy_of_ceremony_country_in_uk_marriage,
            :get_legal_and_travel_advice,
            :what_you_need_to_do_affirmation,
            :make_an_appointment_bring_passport_and_pay_55_colombia,
            contact_method_key,
            :link_to_consular_fees,
            :pay_by_cash_or_credit_card_no_cheque,
            :legalisation_and_translation,
            :affirmation_os_translation_in_local_language_text,
            :documents_for_divorced_or_widowed_china_colombia,
            :change_of_name_evidence,
            :names_on_documents_must_match,
            :partner_naturalisation_in_uk
          )
        end
      end

      outcome :outcome_monaco do
        precalculate :monaco_title do
          phrases = PhraseList.new
          if marriage_or_pacs == 'marriage'
            phrases << "Marriage in Monaco"
          else
            phrases << "PACS in Monaco"
          end
          phrases
        end
        precalculate :monaco_phraselist do
          PhraseList.new(:"monaco_#{marriage_or_pacs}")
        end
      end

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

      outcome :outcome_os_commonwealth do
        precalculate :commonwealth_os_outcome do
          phrases = PhraseList.new

          if resident_of == 'uk'
            if ceremony_country == 'zimbabwe'
              phrases << :contact_zimbabwean_embassy_in_uk
            else
              phrases << :contact_high_comission_of_ceremony_country_in_uk
            end
          else
            phrases << :contact_local_authorities_in_country_marriage
          end

          if resident_of == 'ceremony_country'
            phrases << :get_legal_advice
          else
            phrases << :get_legal_and_travel_advice
          end

          if ceremony_country == 'zimbabwe'
            phrases << :cant_issue_cni_for_zimbabwe
          else
            phrases << :cant_issue_cni_for_commonwealth
          end

          case ceremony_country
          when 'south-africa'
            phrases << :commonwealth_os_marriage_subtleties_in_south_africa  if  partner_nationality == 'partner_local'
          when 'india'
            phrases << :commonwealth_os_marriage_subtleties_in_india
            phrases << contact_method_key
          when 'malaysia'
            phrases << :commonwealth_os_marriage_subtleties_in_malaysia
          when 'singapore'
            phrases << :commonwealth_os_marriage_subtleties_in_singapore
          when 'brunei'
            phrases << :commonwealth_os_marriage_subtleties_in_brunei
          when 'cyprus'
            if resident_of == 'ceremony_country'
              phrases << :commonwealth_os_marriage_subtleties_in_cyprus
            end
          end
          unless partner_nationality == 'partner_british'
            phrases << :partner_naturalisation_in_uk
          end
          phrases
        end
      end

      outcome :outcome_os_bot do
        precalculate :bot_outcome do
          phrases = PhraseList.new
          if ceremony_country == 'british-indian-ocean-territory'
            phrases << :bot_os_ceremony_biot
            phrases << contact_method_key
          elsif ceremony_country == 'british-virgin-islands'
            phrases << :bot_os_ceremony_bvi
            phrases << :get_legal_advice
          else
            phrases << :bot_os_ceremony_non_biot
            phrases << contact_method_key

            if resident_of == 'ceremony_country'
              phrases << :get_legal_advice
            else
              phrases << :get_legal_and_travel_advice
            end
            unless partner_nationality == 'partner_british'
              phrases << :partner_naturalisation_in_uk
            end
          end
          phrases
        end
      end

      outcome :outcome_consular_cni_os_residing_in_third_country do
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
          phrases << :contact_local_authorities_in_country_marriage
          phrases << :get_legal_and_travel_advice
          if data_query.os_no_marriage_related_consular_services?(ceremony_country)
            phrases << :cni_os_consular_facilities_unavailable
          end
          phrases << :what_you_need_to_do

          if ceremony_country == 'norway'
            phrases << :what_you_need_to_do_to_marry_in_norway_when_in_third_country
          else
            phrases << :you_may_be_asked_for_cni
            if ceremony_country == 'nicaragua'
              phrases << :getting_cni_from_costa_rica_when_in_third_country
            else
              phrases << :standard_ways_to_get_cni_in_third_country
            end
          end
        end
      end

      outcome :outcome_os_consular_cni do
        precalculate :consular_cni_os_start do
          phrases = PhraseList.new
          three_day_residency_requirement_applies = %w(albania algeria angola armenia austria azerbaijan bahrain belarus bolivia bosnia-and-herzegovina bulgaria chile croatia cuba democratic-republic-of-congo denmark dominican-republic el-salvador estonia ethiopia georgia greece guatemala honduras hungary iceland italy kazakhstan kosovo kuwait kyrgyzstan latvia lithuania luxembourg macedonia mexico moldova montenegro nepal panama poland romania russia serbia slovenia sudan sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
          three_day_residency_handled_by_exception = %w(croatia italy russia)
          no_birth_cert_requirement = three_day_residency_requirement_applies - ['italy']
          cni_notary_public_countries = %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland kazakhstan kuwait kyrgyzstan libya lithuania luxembourg mexico moldova montenegro poland russia serbia sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
          no_document_download_link_if_os_resident_of_uk_countries = %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland italy japan kazakhstan kuwait kyrgyzstan libya lithuania luxembourg macedonia mexico moldova montenegro nicaragua poland russia serbia sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)

          cni_posted_after_14_days_countries = %w(oman jordan qatar saudi-arabia united-arab-emirates yemen)
          ceremony_not_germany_or_not_resident_other = (ceremony_country != 'germany' || resident_of == 'uk') # TODO verify this is ok
          ceremony_and_residency_in_croatia = (ceremony_country == 'croatia' && resident_of == 'ceremony_country')

          if ceremony_country == 'japan'
            phrases << :japan_intro
          end

          if %(japan italy).exclude?(ceremony_country)
            if resident_of == 'uk'
              if data_query.dutch_caribbean_islands?(ceremony_country)
                phrases << :contact_dutch_embassy_for_dutch_caribbean_islands
              else
                phrases << :contact_embassy_of_ceremony_country_in_uk_marriage
              end
            else
              phrases << :contact_local_authorities_in_country_marriage
            end
          end

          if %w(jordan oman qatar).include?(ceremony_country)
            phrases << :gulf_states_os_consular_cni
            if resident_of == 'ceremony_country'
              phrases << :gulf_states_os_consular_cni_local_resident
            end
          end

          if %(japan italy).exclude?(ceremony_country)
            if resident_of == 'ceremony_country'
              phrases << :get_legal_advice
            else
              phrases << :get_legal_and_travel_advice
            end
          end

          if ceremony_country == 'italy'
            phrases << :italy_os_consular_cni_ceremony_italy
          end

          phrases << :what_you_need_to_do

          if ceremony_and_residency_in_croatia
            phrases << :what_to_do_croatia
          elsif %w(montenegro kuwait).include?(ceremony_country) && resident_of != 'uk'
            phrases << :check_with_notary_public_if_you_need_cni
          elsif ceremony_country == 'jordan'
            phrases << :consular_cni_os_foreign_resident_21_days_jordan
          elsif data_query.os_21_days_residency_required_countries?(ceremony_country)
            phrases << :consular_cni_os_ceremony_21_day_requirement
            phrases << :you_may_be_asked_for_cni
          elsif ceremony_country != 'italy' && ceremony_not_germany_or_not_resident_other
            phrases << :you_may_be_asked_for_cni
          end

          if ceremony_country == 'italy'
            if resident_of == 'uk'
              phrases << :get_cni_from_uk
            end
            if resident_of == 'uk' && partner_nationality == 'partner_british'
              phrases << :partner_cni_requirements_the_same
            end
            if resident_of != 'uk'
              phrases << :nulla_osta_requirement
              phrases << contact_method_key
            end
          end

          if ceremony_country == 'denmark'
            phrases << :consular_cni_os_denmark
          elsif ceremony_country == 'germany' && resident_of != 'uk'
            phrases << :consular_cni_requirements_in_germany
          end

          if resident_of == 'uk'
            phrases << :cni_at_local_register_office
            phrases << :cni_issued_locally_validity
            if cni_posted_after_14_days_countries.include?(ceremony_country)
              phrases << :cni_subject_to_objection_14_days
            end

            if ceremony_country == 'italy'
              if partner_nationality == 'partner_british'
                phrases << :getting_statutory_declaration_for_italy_partner_british
              else
                phrases << :getting_statutory_declaration_for_italy_partner_non_british
              end
              phrases << :bilingual_statutory_declaration_download_for_italy

              if partner_nationality != 'partner_british'
                phrases << :statutory_declaration_for_non_british_partner
              end

              phrases << :legalising_italian_statutory_declaration
            end
          end

          if resident_of == 'uk'
            if ceremony_country == 'tunisia'
              phrases << :tunisia_legalisation_and_translation
            elsif ceremony_country == 'germany'
              phrases << :germany_legalisation_and_translation
            elsif ceremony_country == 'montenegro'
              phrases << :consular_cni_os_uk_resident_montenegro
            elsif %w(finland kazakhstan kyrgyzstan poland).include?(ceremony_country)
              phrases << :legalisation_and_translation_check_with_authorities
            elsif ceremony_country == 'greece'
              phrases << :legalisation_and_translation
              phrases << :uk_cni_accepted_in_townhall
            elsif %w(italy).exclude?(ceremony_country)
              phrases << :legisation_and_translation_intro_uk
            end

            if %w(germany italy tunisia).exclude?(ceremony_country)
              phrases << :legalise_translate_and_check_with_authorities
            end
          end

          if resident_of == 'ceremony_country'

            if ceremony_country == 'croatia'
              phrases << :consular_cni_os_local_resident_table
            elsif ceremony_country == 'nicaragua'
              phrases << :arrange_cni_via_costa_rica
            elsif %w(germany italy kazakhstan macedonia russia).exclude?(ceremony_country)
              phrases << :consular_cni_os_giving_notice_in_ceremony_country
            end

            if three_day_residency_handled_by_exception.exclude?(ceremony_country) && three_day_residency_requirement_applies.include?(ceremony_country)
              phrases << :living_in_ceremony_country_3_days
            end

            if ceremony_country == 'estonia' && resident_of == 'ceremony_country'
              phrases << :cni_exception_for_permanent_residents_estonia
            end

            if %w(kazakhstan kyrgyzstan).include?(ceremony_country)
              phrases << :kazakhstan_os_local_resident
            elsif ceremony_country == 'russia'
              phrases << :russia_os_local_resident
            end

            unless %w(germany italy japan).include?(ceremony_country)
              if ceremony_country == 'macedonia'
                phrases << :consular_cni_os_foreign_resident_3_days_macedonia
              else
                phrases << contact_method_key
              end
            end
            if ceremony_country == 'italy'
              phrases << :consular_cni_os_local_resident_italy
            end
          end

          if resident_of != 'uk' && data_query.phrase_exists?("required_supporting_documents_#{ceremony_country}")
            phrases << :"required_supporting_documents_#{ceremony_country}"
          elsif resident_of == 'ceremony_country' && %w(germany italy japan).exclude?(ceremony_country)
            birth_cert_inclusion = if no_birth_cert_requirement.exclude?(ceremony_country)
              '_incl_birth_cert'
            end

            notary_public_inclusion = if cni_notary_public_countries.include?(ceremony_country) || %w(japan macedonia).include?(ceremony_country)
              '_notary_public'
            end
            phrases << "required_supporting_documents#{birth_cert_inclusion}#{notary_public_inclusion}".to_sym

            if ceremony_country == 'jordan'
              phrases << :documents_must_be_originals_when_in_sharia_court
            end
          end

          if resident_of == 'ceremony_country'
            if ceremony_country == 'japan'
              phrases << contact_method_key
              phrases << :japan_consular_cni_os_local_resident
            end
            if ceremony_country == 'italy'
              if partner_nationality == 'partner_british'
                phrases << :italy_consular_cni_os_partner_british
              else
                phrases << :italy_consular_cni_os_partner_not_british
              end
            end
          end

          if resident_of != 'uk'
            if ceremony_country == 'jordan'
              phrases << :consular_cni_os_not_uk_resident_ceremony_jordan
            elsif ceremony_country != 'germany'
              phrases << :consular_cni_os_not_uk_resident_ceremony_not_germany
            end
          end

          if resident_of != 'uk'
            if ceremony_country == 'italy' && resident_of != 'uk'
              phrases << :consular_cni_os_other_resident_ceremony_italy
            elsif %(germany).exclude?(ceremony_country)
              phrases << :evidence_if_divorced_outside_uk
            end
          end

          if ceremony_country == 'italy' && resident_of != 'uk'
            phrases << :wait_300_days_before_remarrying
          end

          if resident_of == 'ceremony_country'
            if %w(germany).exclude?(ceremony_country)
              phrases << :download_and_fill_notice_and_affidavit_but_not_sign
            end
          else
            if sex_of_your_partner == 'same_sex' || no_document_download_link_if_os_resident_of_uk_countries.exclude?(ceremony_country) && (cni_notary_public_countries + %w(italy japan macedonia) - %w(greece tunisia)).include?(ceremony_country)
              phrases << :download_and_fill_notice_and_affidavit_but_not_sign
            end
          end

          if resident_of == 'ceremony_country'
            if ceremony_country == 'kazakhstan'
              phrases << :display_notice_of_marriage_7_days
            elsif ceremony_country == 'italy'
              phrases << :issuing_cni_in_italy
            elsif ceremony_country == 'greece'
              phrases << :consular_cni_os_foreign_resident_ceremony_notary_public_greece
            elsif cni_notary_public_countries.include?(ceremony_country) || ceremony_country == 'japan'
              phrases << :consular_cni_os_foreign_resident_ceremony_notary_public
            elsif %w(germany).exclude?(ceremony_country)
              phrases << :display_notice_of_marriage_7_days
            end
          elsif data_query.requires_7_day_notice?(ceremony_country)
            phrases << :display_notice_of_marriage_7_days
          end
          phrases
        end

        precalculate :consular_cni_os_remainder do
          phrases = PhraseList.new

          if ceremony_country != 'italy' && resident_of == 'uk' && "partner_other" == partner_nationality && "finland" == ceremony_country
            phrases << :callout_partner_equivalent_document
          end

          if partner_nationality == 'partner_british' && %w(italy germany finland).exclude?(ceremony_country)
            phrases << :same_cni_process_and_fees_for_partner
          end

          if ceremony_country != 'germany'  || (ceremony_country == 'germany' && resident_of == 'uk')
            phrases << :names_on_documents_must_match
          end

          if resident_of != 'uk' && %w(italy germany).exclude?(ceremony_country)
            phrases << :check_if_cni_needs_to_be_legalised
          end

          if resident_of == 'ceremony_country'
            phrases << :no_need_to_stay_after_posting_notice
          end

          if partner_nationality != 'partner_british'
            phrases << :partner_naturalisation_in_uk
          end

          unless ceremony_country == 'italy' && resident_of == 'uk'
            if ceremony_country == 'croatia' && resident_of == 'ceremony_country'
              phrases << :fee_table_croatia
            elsif ceremony_country == 'italy'
              phrases << :list_of_consular_fees_italy
            else
              phrases << :consular_cni_os_fees_incl_null_osta_oath_consular_letter
            end

            unless data_query.countries_without_consular_facilities?(ceremony_country) || ceremony_country == 'cote-d-ivoire'
              if %w(kazakhstan kyrgyzstan).include?(ceremony_country)
                phrases << :list_of_consular_kazakhstan
              else
                phrases << :link_to_consular_fees
              end
            end
          end

          unless data_query.countries_without_consular_facilities?(ceremony_country)
            if %w(armenia bosnia-and-herzegovina cambodia iceland latvia slovenia tunisia tajikistan).include?(ceremony_country)
              phrases << :pay_in_local_currency_ceremony_country_name
            elsif %w(kazakhstan kyrgyzstan).include?(ceremony_country)
              phrases << :pay_in_local_currency_ceremony_in_kazakhstan
            elsif ceremony_country == 'luxembourg'
              phrases << :pay_in_cash_visa_or_mastercard
            elsif ceremony_country == 'russia'
              phrases << :pay_by_mastercard_or_visa
            elsif ceremony_country == 'finland'
              phrases << :pay_in_euros_or_visa_electron
            elsif ceremony_country == 'kuwait'
              phrases << :pay_by_card_no_amex_no_cheque
            elsif %w(cote-d-ivoire burundi).exclude?(ceremony_country) && !(ceremony_country == 'italy' && resident_of == 'uk')
              phrases << :pay_by_cash_or_credit_card_no_cheque
            end
          end
          phrases
        end
      end

      outcome :outcome_os_france_or_fot do
        precalculate :france_or_fot_os_outcome do
          phrases = PhraseList.new
          if data_query.french_overseas_territories?(ceremony_country)
            phrases << :fot_os_rules_similar_to_france
          end
          phrases
        end
      end

      outcome :outcome_os_affirmation do
        precalculate :affirmation_os_outcome do
          phrases = PhraseList.new

          if ceremony_country == 'macao' && resident_of != 'ceremony_country'
            phrases << :one_must_be_a_resident
          end

          if resident_of == 'uk'
            phrases << :contact_embassy_of_ceremony_country_in_uk_marriage
            if ceremony_country == 'morocco'
              phrases << :contact_laadoul
            end
          elsif resident_of == 'ceremony_country' || ceremony_country == 'qatar'
            phrases << :contact_local_authorities_in_country_marriage
            if ceremony_country == 'qatar'
              phrases << :gulf_states_os_consular_cni << :gulf_states_os_consular_cni_local_resident
            end
          elsif resident_of == 'third_country'
            phrases << :contact_local_authorities_in_country_marriage
            if ceremony_country == 'morocco'
              phrases << :contact_laadoul
            end
          end

          if %w(cambodia ecuador).exclude?(ceremony_country)
            if resident_of == 'ceremony_country'
              phrases << :get_legal_advice
            else
              phrases << :get_legal_and_travel_advice
            end
          end

          if ceremony_country == 'united-arab-emirates'
            phrases << :affirmation_os_uae
          end

          if %w(turkey egypt china).include?(ceremony_country)
            phrases << :what_you_need_to_do
          elsif data_query.os_21_days_residency_required_countries?(ceremony_country)
            phrases << :what_you_need_to_do_affirmation_21_days
          else
            phrases << :what_you_need_to_do_affirmation
          end

          if ceremony_country == 'turkey' && resident_of == 'uk'
            phrases << :appointment_for_affidavit_notary
          elsif ceremony_country == 'philippines'
            phrases << :contact_for_affidavit
          elsif ceremony_country == 'egypt'
            phrases << :make_an_appointment
          elsif ceremony_country == 'china'
            prelude = "book_online_china_#{partner_nationality != 'partner_local' ? 'non_' : ''}local_prelude".to_sym
            phrases << prelude
            phrases << contact_method_key
            phrases << :book_online_china_affirmation_affidavit
          elsif ceremony_country == 'norway'
            phrases << :appointment_for_affidavit_norway
          elsif ceremony_country == 'macao'
            phrases << :appointment_for_affidavit_in_hong_kong
          else
            phrases << :appointment_for_affidavit
          end

          unless %w(china turkey).include?(ceremony_country)
            phrases << contact_method_key
            if ceremony_country == 'belgium'
              phrases << :complete_affirmation_or_affidavit_forms
              phrases << :download_and_fill_but_not_sign
              phrases << :download_affidavit_and_affirmation_belgium
              phrases << :partner_needs_affirmation
              phrases << :required_supporting_documents
              phrases << :documents_guidance_belgium
            end

            if ceremony_country == 'philippines'
              phrases << :required_supporting_documents_philippines
            end

            if ceremony_country == 'macao'
              phrases << :complete_affirmation_or_affidavit_forms
              phrases << :download_and_fill_but_not_sign
              phrases << :download_affidavit_and_affirmation_macao
              phrases << :required_supporting_documents_macao
              phrases << :partner_probably_needs_affirmation
            end

            if ceremony_country == 'cambodia'
              phrases << :fee_and_required_supporting_documents_for_appointment
              phrases << :legalisation_and_translation
              phrases << :affirmation_os_translation_in_local_language_text
            elsif ceremony_country == 'egypt'
              phrases << :required_supporting_documents_egypt
              if partner_nationality == 'partner_local'
                phrases << :partner_needs_egyptian_id
              end
            else
              phrases << :legalisation_and_translation
              phrases << :affirmation_os_translation_in_local_language_text
            end
          end
          if ceremony_country == 'philippines'
            phrases << :affirmation_os_download_affidavit_philippines
          end

          if ceremony_country == 'turkey' && resident_of != 'uk'
            phrases << contact_method_key
          end
          if ceremony_country == 'turkey'
            phrases << :complete_affidavit << :download_affidavit
            if resident_of == 'ceremony_country'
              phrases << :affirmation_os_legalised_in_turkey
            else
              phrases << :affirmation_os_legalised
            end
            phrases << :documents_for_divorced_or_widowed
          end

          if ceremony_country == 'morocco'
            phrases << :documents_for_divorced_or_widowed
          elsif ceremony_country == 'ecuador'
            phrases << :documents_for_divorced_or_widowed_ecuador
          elsif ceremony_country == 'cambodia'
            phrases << :documents_for_divorced_or_widowed_cambodia
            phrases << :change_of_name_evidence
          elsif ceremony_country == 'china'
            phrases << :documents_for_divorced_or_widowed_china_colombia
          elsif ceremony_country == 'philippines'
            phrases << :documents_for_divorced_or_widowed_philippines
          elsif ceremony_country != 'turkey'
            phrases << :docs_decree_and_death_certificate
          end

          if %w(cambodia china ecuador egypt morocco philippines turkey).exclude?(ceremony_country)
            phrases << :divorced_or_widowed_evidences
          end
          if %w(cambodia ecuador morocco philippines turkey).exclude?(ceremony_country)
            phrases << :change_of_name_evidence
          end

          if ceremony_country == 'egypt'
            if partner_nationality == 'partner_british'
              phrases << :partner_declaration
            else
              phrases << :callout_partner_equivalent_document
            end
          end
          unless ceremony_country == 'egypt'
            if ceremony_country == 'turkey'
              if partner_nationality == 'partner_british'
                phrases << :partner_needs_affirmation
              else
                phrases << :callout_partner_equivalent_document
                phrases << :check_legalised_document
              end
            elsif ceremony_country == 'morocco'
              phrases << :morocco_affidavit_length
              phrases << :partner_equivalent_document
            else
              if partner_nationality == 'partner_british'
                phrases << :partner_probably_needs_affirmation
              else
                if ceremony_country == 'china' && partner_nationality != 'partner_local'
                  phrases << :partner_probably_needs_affirmation_or_affidavit
                else
                  phrases << :callout_partner_equivalent_document
                  if %w(belgium cambodia ecuador).include?(ceremony_country)
                    phrases << :names_on_documents_must_match
                  end
                  phrases << :partner_naturalisation_in_uk
                end
              end
            end
          end

          #fee tables
          if %w(south-korea thailand turkey vietnam).include?(ceremony_country)
            phrases << :fee_table_affidavit_55
          elsif %w(belgium cambodia ecuador macao morocco norway).include?(ceremony_country)
            phrases << :fee_table_affirmation_55
          elsif ceremony_country == 'finland'
            phrases << :fee_table_affirmation_65
          elsif ceremony_country == 'philippines'
            phrases << :fee_table_55_70
          elsif ceremony_country == 'qatar'
            phrases << :fee_table_45_70_55
          elsif ceremony_country == 'egypt'
            phrases << :fee_table_55_55
          else
            phrases << :affirmation_os_all_fees_45_70
          end
          unless data_query.countries_without_consular_facilities?(ceremony_country)
            if ceremony_country != 'cambodia'
              phrases << :link_to_consular_fees
            end

            if ceremony_country == 'finland'
              phrases << :pay_in_euros_or_visa_electron
            elsif ceremony_country == 'philippines'
              phrases << :pay_in_cash_only
            elsif ceremony_country == 'cambodia'
              phrases << :pay_by_cash_or_us_dollars_only
            elsif ceremony_country == 'norway'
              phrases << :pay_by_visas_or_mastercard
            else
              phrases << :pay_by_cash_or_credit_card_no_cheque
            end
          end
          phrases
        end
      end

      outcome :outcome_os_no_cni do
        precalculate :no_cni_os_outcome do
          phrases = PhraseList.new
          if data_query.dutch_caribbean_islands?(ceremony_country)
            phrases << :country_is_dutch_caribbean_island
            if resident_of == 'uk'
              phrases << :contact_dutch_embassy_in_uk
            else
              phrases << :contact_local_authorities_in_country_marriage
            end
          else
            if resident_of != 'uk' || data_query.ss_unknown_no_embassies?(ceremony_country)
              phrases << :contact_local_authorities_in_country_marriage
            elsif resident_of == 'uk'
              phrases << :contact_embassy_or_consulate_representing_ceremony_country_in_uk
            end
          end

          if resident_of == 'ceremony_country'
            phrases << :get_legal_advice
          else
            phrases << :get_legal_and_travel_advice
          end

          phrases << :cni_os_consular_facilities_unavailable

          unless data_query.countries_without_consular_facilities?(ceremony_country)
            phrases << :link_to_consular_fees
            phrases << :pay_by_cash_or_credit_card_no_cheque
          end
          if partner_nationality != 'partner_british'
            phrases << :partner_naturalisation_in_uk
          end
          if data_query.requires_7_day_notice?(ceremony_country)
            phrases << :display_notice_of_marriage_7_days
          end

          phrases
        end
      end

      outcome :outcome_os_other_countries do
        precalculate :other_countries_os_outcome do
          phrases = PhraseList.new
          case ceremony_country
          when 'burma'
            phrases << :embassy_in_burma_doesnt_register_marriages
            if partner_nationality == 'partner_local'
              phrases << :cant_marry_burmese_citizen
            end
          when 'north-korea'
            phrases << :marriage_in_north_korea_unlikely
            if partner_nationality == 'partner_local'
              phrases << :cant_marry_north_korean_citizen
            end
          when *%w(iran somalia syria)
            phrases << :no_consular_services_contact_embassy
          when 'yemen'
            phrases << :limited_consular_services_contact_embassy
          when 'saudi-arabia'
            if resident_of != 'ceremony_country'
              phrases << :saudi_arabia_requirements_for_foreigners
              phrases << contact_method_key
            else
              phrases << :saudi_arabia_requirements_for_residents
              if partner_nationality != 'partner_british'
                phrases << :partner_naturalisation_in_uk
              end
              phrases << :fees_table_and_payment_instructions_saudi_arabia
            end
          else
            raise "The outcome for #{ceremony_country} is not handled"
          end
          phrases
        end
      end

      #CP outcomes
      outcome :outcome_cp_or_equivalent do
        precalculate :cp_or_equivalent_cp_outcome do
          phrases = PhraseList.new
          if data_query.cp_equivalent_countries?(ceremony_country)
            phrases << :"synonyms_of_cp_in_#{ceremony_country}"
          end

          if ceremony_country == 'brazil' && sex_of_your_partner == 'same_sex' && resident_of != 'ceremony_country'
            phrases << :check_travel_advice
          elsif resident_of == 'uk'
            phrases << :contact_embassy_of_ceremony_country_in_uk_cp
          else
            phrases << :contact_local_authorities_in_country_cp
          end

          if resident_of != 'ceremony_country' && ceremony_country != 'brazil'
            phrases << :also_check_travel_advice
          end

          unless ceremony_country == 'czech-republic' && sex_of_your_partner == 'same_sex'
            if ceremony_country == 'brazil' && sex_of_your_partner == 'same_sex' && resident_of == 'uk'
              phrases << :what_you_need_to_do_cni_cp << :cni_at_local_register_office << :cni_issued_locally_validity << :legisation_and_translation_intro_uk << :legalise_translate_and_check_with_authorities << :names_on_documents_must_match
            else
              phrases << :cp_or_equivalent_cp_what_you_need_to_do
              phrases << contact_method_key
            end
          end
          if partner_nationality != 'partner_british'
            phrases << :partner_naturalisation_in_uk
          end
          unless ceremony_country == 'czech-republic' && sex_of_your_partner == 'same_sex'
            phrases << :standard_cni_fee_for_cp
          end

          unless (ceremony_country == 'czech-republic' || data_query.countries_without_consular_facilities?(ceremony_country))
            phrases << :link_to_consular_fees
          end

          if %w(iceland slovenia).include?(ceremony_country)
            phrases << :pay_in_local_currency_ceremony_country_name
          elsif ceremony_country == 'luxembourg'
            phrases << :pay_in_cash_visa_or_mastercard
          elsif %w(czech-republic cote-d-ivoire).exclude?(ceremony_country)
            phrases << :pay_by_cash_or_credit_card_no_cheque
          end
          phrases
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
