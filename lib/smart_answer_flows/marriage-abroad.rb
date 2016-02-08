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
      content_id "d0a95767-f6ab-432a-aebc-096e37fb3039"
      name 'marriage-abroad'
      status :published
      satisfies_need "101000"

      data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
      country_name_query = SmartAnswer::Calculators::CountryNameFormatter.new
      reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
      exclude_countries = %w(holy-see british-antarctic-territory the-occupied-palestinian-territories)

      # Q1
      country_select :country_of_ceremony?, exclude_countries: exclude_countries do
        next_node_calculation :calculator do
          Calculators::MarriageAbroadCalculator.new
        end

        calculate :resident_of do
          nil
        end
        calculate :pay_by_cash_or_credit_card_no_cheque do
          nil
        end

        calculate :location do
          loc = WorldLocation.find(calculator.ceremony_country)
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
          if data_query.ss_marriage_countries?(calculator.ceremony_country) || data_query.ss_marriage_countries_when_couple_british?(calculator.ceremony_country)
            "ss_marriage"
          elsif data_query.ss_marriage_and_partnership?(calculator.ceremony_country)
            "ss_marriage_and_partnership"
          end
        end

        calculate :ceremony_country_name do
          location.name
        end

        calculate :country_name_lowercase_prefix do
          if country_name_query.class::COUNTRIES_WITH_DEFINITIVE_ARTICLES.include?(calculator.ceremony_country)
            country_name_query.definitive_article(calculator.ceremony_country)
          elsif country_name_query.class::FRIENDLY_COUNTRY_NAME.has_key?(calculator.ceremony_country)
            country_name_query.class::FRIENDLY_COUNTRY_NAME[calculator.ceremony_country].html_safe
          else
            ceremony_country_name
          end
        end

        calculate :country_name_uppercase_prefix do
          country_name_query.definitive_article(calculator.ceremony_country, true)
        end

        calculate :country_name_partner_residence do
          if data_query.british_overseas_territories?(calculator.ceremony_country)
            "British (overseas territories citizen)"
          elsif data_query.french_overseas_territories?(calculator.ceremony_country)
            "French"
          elsif data_query.dutch_caribbean_islands?(calculator.ceremony_country)
            "Dutch"
          elsif %w(hong-kong macao).include?(calculator.ceremony_country)
            "Chinese"
          else
            "National of #{country_name_lowercase_prefix}"
          end
        end

        calculate :embassy_or_consulate_ceremony_country do
          if reg_data_query.has_consulate?(calculator.ceremony_country) || reg_data_query.has_consulate_general?(calculator.ceremony_country)
            "consulate"
          else
            "embassy"
          end
        end

        permitted_next_nodes = [
          :legal_residency?,
          :marriage_or_pacs?,
          :outcome_os_france_or_fot,
          :partner_opposite_or_same_sex?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.ceremony_country = response
          if calculator.ceremony_country == 'ireland'
            :partner_opposite_or_same_sex?
          elsif %w(france monaco new-caledonia wallis-and-futuna).include?(calculator.ceremony_country)
            :marriage_or_pacs?
          elsif data_query.french_overseas_territories?(calculator.ceremony_country)
            :outcome_os_france_or_fot
          else
            :legal_residency?
          end
        end
      end

      # Q2
      multiple_choice :legal_residency? do
        option :uk
        option :ceremony_country
        option :third_country

        save_input_as :resident_of

        permitted_next_nodes = [
          :partner_opposite_or_same_sex?,
          :what_is_your_partners_nationality?
        ]
        next_node(permitted: permitted_next_nodes) do
          if calculator.ceremony_country == 'switzerland'
            :partner_opposite_or_same_sex?
          else
            :what_is_your_partners_nationality?
          end
        end
      end

      # Q3a
      multiple_choice :marriage_or_pacs? do
        option :marriage
        option :pacs
        save_input_as :marriage_or_pacs

        permitted_next_nodes = [
          :outcome_cp_france_pacs,
          :outcome_monaco,
          :outcome_os_france_or_fot
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if calculator.ceremony_country == 'monaco'
            :outcome_monaco
          elsif response == 'marriage'
            :outcome_os_france_or_fot
          else
            :outcome_cp_france_pacs
          end
        end
      end

      # Q4
      multiple_choice :what_is_your_partners_nationality? do
        option :partner_british
        option :partner_local
        option :partner_other

        next_node(permitted: [:partner_opposite_or_same_sex?]) do |response|
          calculator.partner_nationality = response
          :partner_opposite_or_same_sex?
        end
      end

      # Q5
      multiple_choice :partner_opposite_or_same_sex? do
        option :opposite_sex
        option :same_sex

        save_input_as :sex_of_your_partner

        next_node_calculation(:ceremony_in_laos_partners_not_local) {
          (calculator.ceremony_country == "laos") && (calculator.partner_is_not_national_of_ceremony_country?)
        }

        next_node_calculation(:ceremony_in_finland_uk_resident) {
          (calculator.ceremony_country == "finland") && (resident_of == "uk")
        }

        next_node_calculation(:ceremony_in_norway_uk_resident) {
          (calculator.ceremony_country == "norway") && (resident_of == "uk")
        }

        next_node_calculation(:ceremony_in_brazil_not_resident_in_the_uk) {
          (calculator.ceremony_country == 'brazil') && (resident_of != 'uk')
        }

        next_node_calculation(:consular_cni_residing_in_third_country) {
          resident_of == 'third_country' && (data_query.os_consular_cni_countries?(calculator.ceremony_country) || %w(kosovo).include?(calculator.ceremony_country) || data_query.os_consular_cni_in_nearby_country?(calculator.ceremony_country))
        }

        next_node_calculation(:marriage_in_norway_third_country) {
          calculator.ceremony_country == 'norway' && resident_of == 'third_country'
        }

        next_node_calculation(:marriage_via_local_authorities) {
          data_query.os_marriage_via_local_authorities?(calculator.ceremony_country)
        }

        next_node_calculation(:marriage_in_italy) {
          calculator.ceremony_country == 'italy'
        }

        next_node_calculation(:ss_marriage_germany_partner_local) { |response|
          response == 'same_sex' && (calculator.ceremony_country == "germany") && (calculator.partner_is_national_of_ceremony_country?)
        }
        next_node_calculation(:ss_marriage_countries) { |response|
          response == 'same_sex' && data_query.ss_marriage_countries?(calculator.ceremony_country)
        }
        next_node_calculation(:ss_marriage_countries_when_couple_british) { |response|
          response == 'same_sex' && data_query.ss_marriage_countries_when_couple_british?(calculator.ceremony_country) && calculator.partner_british?
        }
        next_node_calculation(:ss_marriage_and_partnership) { |response|
          response == 'same_sex' && data_query.ss_marriage_and_partnership?(calculator.ceremony_country)
        }

        next_node_calculation(:ss_marriage_not_possible) { |response|
          response == 'same_sex' && data_query.ss_marriage_not_possible?(calculator.ceremony_country, calculator)
        }

        next_node_calculation(:ss_unknown_no_embassies) { |response|
          response == 'same_sex' && data_query.ss_unknown_no_embassies?(calculator.ceremony_country)
        }

        next_node_calculation(:ss_affirmation) { |response|
          response == 'same_sex' && %w(belgium norway).include?(calculator.ceremony_country)
        }

        permitted_next_nodes = [
          :outcome_brazil_not_living_in_the_uk,
          :outcome_consular_cni_os_residing_in_third_country,
          :outcome_cp_all_other_countries,
          :outcome_cp_commonwealth_countries,
          :outcome_cp_consular,
          :outcome_cp_no_cni,
          :outcome_cp_or_equivalent,
          :outcome_ireland,
          :outcome_marriage_via_local_authorities,
          :outcome_os_affirmation,
          :outcome_os_belarus,
          :outcome_os_bot,
          :outcome_os_cambodia,
          :outcome_os_colombia,
          :outcome_os_commonwealth,
          :outcome_os_consular_cni,
          :outcome_os_germany,
          :outcome_os_hong_kong,
          :outcome_os_indonesia,
          :outcome_os_italy,
          :outcome_os_kosovo,
          :outcome_os_kuwait,
          :outcome_os_laos,
          :outcome_os_japan,
          :outcome_os_marriage_impossible_no_laos_locals,
          :outcome_os_no_cni,
          :outcome_os_oman,
          :outcome_os_other_countries,
          :outcome_os_poland,
          :outcome_os_slovenia,
          :outcome_portugal,
          :outcome_spain,
          :outcome_ss_affirmation,
          :outcome_ss_marriage,
          :outcome_ss_marriage_malta,
          :outcome_ss_marriage_not_possible,
          :outcome_switzerland
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if ceremony_in_brazil_not_resident_in_the_uk
            :outcome_brazil_not_living_in_the_uk
          elsif calculator.ceremony_country == "netherlands"
            :outcome_marriage_via_local_authorities
          elsif calculator.ceremony_country == "portugal"
            :outcome_portugal
          elsif calculator.ceremony_country == "ireland"
            :outcome_ireland
          elsif calculator.ceremony_country == "switzerland"
            :outcome_switzerland
          elsif calculator.ceremony_country == "spain"
            :outcome_spain
          elsif response == 'opposite_sex'
            if calculator.ceremony_country == 'hong-kong'
              :outcome_os_hong_kong
            elsif calculator.ceremony_country == 'germany'
              :outcome_os_germany
            elsif calculator.ceremony_country == 'oman'
              :outcome_os_oman
            elsif calculator.ceremony_country == 'belarus'
              :outcome_os_belarus
            elsif calculator.ceremony_country == 'kuwait'
              :outcome_os_kuwait
            elsif consular_cni_residing_in_third_country
              :outcome_consular_cni_os_residing_in_third_country
            elsif marriage_in_norway_third_country
              :outcome_consular_cni_os_residing_in_third_country
            elsif marriage_in_italy
              :outcome_os_italy
            elsif calculator.ceremony_country == 'cambodia'
              :outcome_os_cambodia
            elsif calculator.ceremony_country == "colombia"
              :outcome_os_colombia
            elsif calculator.ceremony_country == 'japan'
              :outcome_os_japan
            elsif calculator.ceremony_country == 'germany'
              :outcome_os_germany
            elsif calculator.ceremony_country == "kosovo"
              :outcome_os_kosovo
            elsif calculator.ceremony_country == "indonesia"
              :outcome_os_indonesia
            elsif ceremony_in_laos_partners_not_local
              :outcome_os_marriage_impossible_no_laos_locals
            elsif calculator.ceremony_country == "laos"
              :outcome_os_laos
            elsif calculator.ceremony_country == 'poland'
              :outcome_os_poland
            elsif calculator.ceremony_country == 'slovenia'
              :outcome_os_slovenia
            elsif data_query.os_consular_cni_countries?(calculator.ceremony_country) || (resident_of == 'uk' && data_query.os_no_marriage_related_consular_services?(calculator.ceremony_country)) || data_query.os_consular_cni_in_nearby_country?(calculator.ceremony_country)
              :outcome_os_consular_cni
            elsif ceremony_in_finland_uk_resident
              :outcome_os_consular_cni
            elsif ceremony_in_norway_uk_resident
              :outcome_os_consular_cni
            elsif data_query.os_affirmation_countries?(calculator.ceremony_country)
              :outcome_os_affirmation
            elsif data_query.commonwealth_country?(calculator.ceremony_country) || calculator.ceremony_country == 'zimbabwe'
              :outcome_os_commonwealth
            elsif data_query.british_overseas_territories?(calculator.ceremony_country)
              :outcome_os_bot
            elsif data_query.os_no_consular_cni_countries?(calculator.ceremony_country) || (resident_of != 'uk' && data_query.os_no_marriage_related_consular_services?(calculator.ceremony_country))
              :outcome_os_no_cni
            elsif marriage_via_local_authorities
              :outcome_marriage_via_local_authorities
            elsif data_query.os_other_countries?(calculator.ceremony_country)
              :outcome_os_other_countries
            end
          elsif response == 'same_sex'
            if ss_affirmation
              :outcome_ss_affirmation
            elsif ss_unknown_no_embassies
              :outcome_os_no_cni
            elsif calculator.ceremony_country == "malta"
              :outcome_ss_marriage_malta
            elsif ss_marriage_not_possible
              :outcome_ss_marriage_not_possible
            elsif ss_marriage_germany_partner_local
              :outcome_cp_or_equivalent
            elsif ss_marriage_countries | ss_marriage_countries_when_couple_british | ss_marriage_and_partnership
              :outcome_ss_marriage
            elsif data_query.cp_equivalent_countries?(calculator.ceremony_country)
              :outcome_cp_or_equivalent
            elsif data_query.cp_cni_not_required_countries?(calculator.ceremony_country)
              :outcome_cp_no_cni
            elsif %w(canada south-africa).include?(calculator.ceremony_country)
              :outcome_cp_commonwealth_countries
            elsif data_query.cp_consular_countries?(calculator.ceremony_country)
              :outcome_cp_consular
            else
              :outcome_cp_all_other_countries
            end
          end
        end
      end

      outcome :outcome_ireland

      outcome :outcome_switzerland

      outcome :outcome_marriage_via_local_authorities

      outcome :outcome_portugal

      outcome :outcome_os_germany

      outcome :outcome_os_kuwait do
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

      outcome :outcome_os_indonesia

      outcome :outcome_os_laos

      outcome :outcome_os_japan

      outcome :outcome_os_hong_kong

      outcome :outcome_os_kosovo

      outcome :outcome_brazil_not_living_in_the_uk

      outcome :outcome_os_cambodia

      outcome :outcome_os_colombia

      outcome :outcome_os_oman

      outcome :outcome_os_poland

      outcome :outcome_os_slovenia

      outcome :outcome_monaco

      outcome :outcome_spain do
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

      outcome :outcome_os_commonwealth

      outcome :outcome_os_bot

      outcome :outcome_os_belarus

      outcome :outcome_os_italy

      outcome :outcome_consular_cni_os_residing_in_third_country do
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

      outcome :outcome_os_consular_cni do
        precalculate :data_query do
          data_query
        end
        precalculate :three_day_residency_requirement_applies do
          %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria chile croatia cuba democratic-republic-of-congo denmark dominican-republic el-salvador estonia ethiopia georgia greece guatemala honduras hungary iceland italy kazakhstan kosovo kuwait kyrgyzstan latvia lithuania luxembourg macedonia mexico moldova montenegro nepal panama romania russia serbia slovenia sudan sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
        end
        precalculate :three_day_residency_handled_by_exception do
          %w(croatia italy russia)
        end
        precalculate :no_birth_cert_requirement do
          three_day_residency_requirement_applies - ['italy']
        end
        precalculate :cni_notary_public_countries do
          %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland kazakhstan kuwait kyrgyzstan libya lithuania luxembourg mexico moldova montenegro russia serbia sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
        end
        precalculate :no_document_download_link_if_os_resident_of_uk_countries do
          %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland italy japan kazakhstan kuwait kyrgyzstan libya lithuania luxembourg macedonia mexico moldova montenegro nicaragua russia serbia sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
        end
        precalculate :cni_posted_after_14_days_countries do
          %w(jordan qatar saudi-arabia united-arab-emirates yemen)
        end
        precalculate :ceremony_not_germany_or_not_resident_other do
          (calculator.ceremony_country != 'germany' || resident_of == 'uk')
        end
        precalculate :ceremony_and_residency_in_croatia do
          (calculator.ceremony_country == 'croatia' && resident_of == 'ceremony_country')
        end
        precalculate :birth_cert_inclusion do
          if no_birth_cert_requirement.exclude?(calculator.ceremony_country)
            '_incl_birth_cert'
          end
        end
        precalculate :notary_public_inclusion do
          if cni_notary_public_countries.include?(calculator.ceremony_country) || %w(japan macedonia).include?(calculator.ceremony_country)
            '_notary_public'
          end
        end
      end

      outcome :outcome_os_france_or_fot do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_os_affirmation do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_os_no_cni do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_os_other_countries

      #CP outcomes
      outcome :outcome_cp_or_equivalent do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_cp_france_pacs

      outcome :outcome_cp_no_cni do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_cp_commonwealth_countries

      outcome :outcome_cp_consular do
        precalculate :institution_name do
          if calculator.ceremony_country == 'cyprus'
            "High Commission"
          else
            "British embassy or consulate"
          end
        end
      end

      outcome :outcome_cp_all_other_countries

      outcome :outcome_ss_marriage do
        precalculate :data_query do
          data_query
        end
      end

      outcome :outcome_ss_marriage_not_possible

      outcome :outcome_ss_marriage_malta

      outcome :outcome_ss_affirmation

      outcome :outcome_os_marriage_impossible_no_laos_locals
    end
  end
end
