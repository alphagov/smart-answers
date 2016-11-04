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

      exclude_countries = %w(holy-see british-antarctic-territory the-occupied-palestinian-territories)

      # Q1
      country_select :country_of_ceremony?, exclude_countries: exclude_countries do
        on_response do |response|
          self.calculator = Calculators::MarriageAbroadCalculator.new
          calculator.ceremony_country = response
        end

        validate do
          calculator.valid_ceremony_country?
        end

        next_node do
          if calculator.ceremony_country == 'ireland'
            question :partner_opposite_or_same_sex?
          elsif calculator.ceremony_country_offers_pacs?
            question :marriage_or_pacs?
          elsif calculator.ceremony_country_is_french_overseas_territory?
            outcome :outcome_marriage_in_france_or_french_overseas_territory
          else
            question :legal_residency?
          end
        end
      end

      # Q2
      multiple_choice :legal_residency? do
        option :uk
        option :ceremony_country
        option :third_country

        on_response do |response|
          calculator.resident_of = response
        end

        next_node do
          if calculator.ceremony_country == 'switzerland'
            question :partner_opposite_or_same_sex?
          else
            question :what_is_your_partners_nationality?
          end
        end
      end

      # Q3a
      multiple_choice :marriage_or_pacs? do
        option :marriage
        option :pacs

        on_response do |response|
          calculator.marriage_or_pacs = response
        end

        next_node do
          if calculator.want_to_get_married?
            if calculator.ceremony_country == 'monaco'
              outcome :outcome_marriage_in_monaco
            else
              outcome :outcome_marriage_in_france_or_french_overseas_territory
            end
          else
            if calculator.ceremony_country == 'monaco'
              outcome :outcome_civil_partnership_in_monaco
            else
              outcome :outcome_civil_partnership_in_france_or_french_overseas_territory
            end
          end
        end
      end

      # Q4
      multiple_choice :what_is_your_partners_nationality? do
        option :partner_british
        option :partner_local
        option :partner_other

        on_response do |response|
          calculator.partner_nationality = response
        end

        next_node do
          question :partner_opposite_or_same_sex?
        end
      end

      # Q5
      multiple_choice :partner_opposite_or_same_sex? do
        option :opposite_sex
        option :same_sex

        on_response do |response|
          calculator.sex_of_your_partner = response
        end

        next_node do
          if calculator.ceremony_country == 'italy'
            outcome :country
          elsif calculator.ceremony_country == 'brazil' && calculator.resident_of_ceremony_country?
            outcome :outcome_marriage_in_brazil_when_residing_in_brazil
          elsif calculator.ceremony_country == 'brazil' && calculator.resident_of_third_country?
            outcome :outcome_marriage_in_brazil_when_residing_in_third_country
          elsif calculator.ceremony_country == "netherlands"
            outcome :outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries
          elsif calculator.ceremony_country == "portugal"
            outcome :outcome_ceremonies_in_portugal
          elsif calculator.ceremony_country == "ireland"
            outcome :outcome_ceremonies_in_ireland
          elsif calculator.ceremony_country == "switzerland"
            outcome :outcome_ceremonies_in_switzerland
          elsif calculator.ceremony_country == "spain"
            outcome :outcome_ceremonies_in_spain
          elsif calculator.ceremony_country == 'sweden' && calculator.resident_of_ceremony_country?
            outcome :outcome_ceremonies_in_sweden_when_residing_in_sweden
          elsif calculator.ceremony_country == 'south-africa'
            outcome :outcome_opposite_same_sex_marriage_residing_in_uk_or_south_africa
          elsif calculator.partner_is_opposite_sex?
            if calculator.ceremony_country == 'hong-kong'
              outcome :outcome_opposite_sex_marriage_in_hong_kong
            elsif calculator.ceremony_country == 'dominican-republic'
              outcome :outcome_opposite_sex_marriage_in_dominican_republic
            elsif calculator.ceremony_country == 'slovakia'
              outcome :outcome_opposite_sex_marriage_in_slovakia
            elsif calculator.ceremony_country == 'germany' && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_germany_when_residing_in_the_uk
            elsif calculator.ceremony_country == 'germany' && calculator.resident_outside_of_uk?
              outcome :outcome_opposite_sex_marriage_in_germany_when_residing_in_germany_or_third_country
            elsif calculator.ceremony_country == 'georgia'
              outcome :outcome_opposite_sex_marriage_in_georgia
            elsif calculator.ceremony_country == 'oman'
              outcome :outcome_opposite_sex_marriage_in_oman
            elsif calculator.ceremony_country == 'belarus'
              outcome :outcome_opposite_sex_marriage_in_belarus
            elsif calculator.ceremony_country == 'kuwait' && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_kuwait_when_residing_in_uk
            elsif calculator.ceremony_country == 'kuwait' && calculator.resident_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_kuwait_when_residing_in_kuwait
            elsif calculator.ceremony_country == 'kuwait' && calculator.resident_of_third_country?
              outcome :outcome_opposite_sex_marriage_in_kuwait_when_residing_in_third_country
            elsif calculator.ceremony_country == 'japan'
              outcome :outcome_opposite_sex_marriage_in_japan
            elsif calculator.ceremony_country == 'rwanda'
              outcome :outcome_opposite_sex_marriage_in_commonwealth_countries
            elsif calculator.ceremony_country == 'bulgaria'
              if calculator.resident_of_uk?
                outcome :outcome_opposite_sex_marriage_in_bulgaria_when_residing_in_uk
              else
                outcome :outcome_opposite_sex_marriage_in_bulgaria_when_residing_in_bulgaria_or_third_country
              end
            elsif calculator.resident_of_third_country? &&
                (
                  calculator.opposite_sex_consular_cni_country? ||
                  %w(kosovo).include?(calculator.ceremony_country) ||
                  calculator.opposite_sex_consular_cni_in_nearby_country?
                )
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
            elsif calculator.ceremony_country == 'norway' && calculator.resident_of_third_country?
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
            elsif calculator.ceremony_country == 'italy' && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_italy_when_residing_in_uk
            elsif calculator.ceremony_country == 'italy' && calculator.resident_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_italy_when_residing_in_italy
            elsif calculator.ceremony_country == 'cambodia'
              outcome :outcome_opposite_sex_marriage_in_cambodia
            elsif calculator.ceremony_country == "colombia"
              outcome :outcome_opposite_sex_marriage_in_colombia
            elsif calculator.ceremony_country == "kosovo" && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_kosovo_when_residing_in_uk
            elsif calculator.ceremony_country == "kosovo" && calculator.resident_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_kosovo_when_residing_in_kosovo
            elsif calculator.ceremony_country == "indonesia"
              outcome :outcome_opposite_sex_marriage_in_indonesia
            elsif calculator.ceremony_country == "laos" && calculator.partner_is_not_national_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_laos_without_lao_national
            elsif calculator.ceremony_country == "laos"
              outcome :outcome_opposite_sex_marriage_in_laos_with_lao_national
            elsif calculator.ceremony_country == 'poland' && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_poland_when_residing_in_uk
            elsif calculator.ceremony_country == 'poland' && calculator.resident_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_poland_when_residing_in_poland
            elsif calculator.ceremony_country == 'slovenia'
              outcome :outcome_opposite_sex_marriage_in_slovenia_when_residing_in_uk_or_slovenia
            elsif calculator.ceremony_country == 'denmark' && (calculator.resident_of_uk? || calculator.resident_of_ceremony_country?)
              outcome :outcome_ceremonies_in_denmark_when_residing_in_uk_or_denmark
            elsif calculator.opposite_sex_consular_cni_country? && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
            elsif calculator.opposite_sex_consular_cni_country? && calculator.resident_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
            elsif calculator.resident_of_uk? &&
                calculator.opposite_sex_no_marriage_related_consular_services_in_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
            elsif calculator.opposite_sex_consular_cni_in_nearby_country? && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
            elsif calculator.opposite_sex_consular_cni_in_nearby_country? && calculator.resident_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
            elsif calculator.ceremony_country == "finland" && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
            elsif calculator.ceremony_country == "norway" && calculator.resident_of_uk?
              outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
            elsif calculator.ceremony_country == 'macao'
              outcome :outcome_opposite_sex_marriage_in_macao
            elsif calculator.ceremony_country == 'morocco'
              outcome :outcome_opposite_sex_marriage_in_morocco
            elsif calculator.ceremony_country == 'qatar'
              outcome :outcome_opposite_sex_marriage_in_qatar
            elsif calculator.ceremony_country == 'ecuador'
              outcome :outcome_opposite_sex_marriage_in_ecuador
            elsif calculator.ceremony_country == 'thailand'
              outcome :outcome_opposite_sex_marriage_in_thailand
            elsif calculator.ceremony_country == 'united-arab-emirates'
              outcome :outcome_opposite_sex_marriage_in_united_arab_emirates
            elsif calculator.ceremony_country == 'turkey'
              outcome :outcome_opposite_sex_marriage_in_turkey
            elsif calculator.ceremony_country == 'egypt'
              outcome :outcome_opposite_sex_marriage_in_egypt
            elsif calculator.ceremony_country == 'china'
              outcome :outcome_opposite_sex_marriage_in_china
            elsif calculator.ceremony_country == 'philippines'
              outcome :outcome_opposite_sex_marriage_in_philippines
            elsif calculator.ceremony_country == 'norway'
              outcome :outcome_opposite_sex_marriage_in_norway
            elsif calculator.ceremony_country == 'south-korea'
              outcome :outcome_opposite_sex_marriage_in_south_korea
            elsif calculator.ceremony_country == 'vietnam'
              outcome :outcome_opposite_sex_marriage_in_vietnam
            elsif calculator.ceremony_country == 'belgium'
              outcome :outcome_opposite_sex_marriage_in_belgium
            elsif calculator.ceremony_country == 'peru'
              outcome :outcome_opposite_sex_marriage_in_peru
            elsif calculator.opposite_sex_affirmation_country?
              outcome :outcome_opposite_sex_marriage_in_affirmation_countries
            elsif calculator.ceremony_country_in_the_commonwealth? ||
                calculator.ceremony_country == 'zimbabwe'
              outcome :outcome_opposite_sex_marriage_in_commonwealth_countries
            elsif calculator.ceremony_country == 'british-indian-ocean-territory'
              outcome :outcome_opposite_sex_marriage_in_british_indian_ocean_territory
            elsif calculator.ceremony_country == 'british-virgin-islands'
              outcome :outcome_opposite_sex_marriage_in_british_virgin_islands
            elsif calculator.ceremony_country_is_british_overseas_territory?
              outcome :outcome_opposite_sex_marriage_in_british_overseas_territory
            elsif calculator.opposite_sex_no_consular_cni_country? ||
                (
                  calculator.resident_outside_of_uk? &&
                  calculator.opposite_sex_no_marriage_related_consular_services_in_ceremony_country?
                )
              outcome :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
            elsif calculator.opposite_sex_marriage_via_local_authorities?
              outcome :outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries
            elsif calculator.ceremony_country == 'burma'
              outcome :outcome_opposite_sex_marriage_in_burma
            elsif calculator.ceremony_country == 'north-korea'
              outcome :outcome_opposite_sex_marriage_in_north_korea
            elsif calculator.ceremony_country == 'yemen'
              outcome :outcome_opposite_sex_marriage_in_yemen
            elsif calculator.ceremony_country == 'saudi-arabia' && calculator.resident_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_saudi_arabia
            elsif calculator.ceremony_country == 'saudi-arabia' && calculator.resident_outside_of_ceremony_country?
              outcome :outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_uk_or_third_country
            elsif %w(iran somalia syria).include?(calculator.ceremony_country)
              outcome :outcome_opposite_sex_marriage_in_other_countries
            end
          elsif calculator.partner_is_same_sex?
            if %w(belgium norway).include?(calculator.ceremony_country)
              outcome :outcome_same_sex_civil_partnership_in_affirmation_countries
            elsif calculator.ceremony_country == 'dominican-republic'
              outcome :outcome_same_sex_marriage_in_dominican_republic
            elsif calculator.ceremony_country == 'italy'
              outcome :outcome_same_sex_marriage_in_italy
            elsif calculator.same_sex_ceremony_country_unknown_or_has_no_embassies?
              outcome :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
            elsif calculator.ceremony_country == "japan"
              outcome :outcome_same_sex_marriage_and_civil_partnership_in_japan
            elsif calculator.ceremony_country == "malta"
              outcome :outcome_same_sex_marriage_and_civil_partnership_in_malta
            elsif calculator.same_sex_marriage_not_possible?
              outcome :outcome_same_sex_marriage_and_civil_partnership_not_possible
            elsif calculator.ceremony_country == "germany" && calculator.partner_is_national_of_ceremony_country?
              outcome :outcome_same_sex_civil_partnership
            elsif calculator.ceremony_country == "romania" && calculator.partner_is_not_national_of_ceremony_country?
              outcome :outcome_same_sex_for_non_romanians
            elsif calculator.same_sex_marriage_country? ||
                (
                  calculator.same_sex_marriage_country_when_couple_british? &&
                  calculator.partner_british?
                ) ||
                calculator.same_sex_marriage_and_civil_partnership?
              outcome :outcome_same_sex_marriage_and_civil_partnership
            elsif calculator.ceremony_country == 'denmark' && (calculator.resident_of_uk? || calculator.resident_of_ceremony_country?)
              outcome :outcome_ceremonies_in_denmark_when_residing_in_uk_or_denmark
            elsif calculator.civil_partnership_equivalent_country?
              outcome :outcome_same_sex_civil_partnership
            elsif calculator.civil_partnership_cni_not_required_country?
              outcome :outcome_same_sex_civil_partnership_in_no_cni_countries
            elsif %w(canada south-africa).include?(calculator.ceremony_country)
              outcome :outcome_same_sex_civil_partnership_in_commonwealth_countries
            elsif calculator.civil_partnership_consular_country?
              outcome :outcome_same_sex_civil_partnership_in_consular_countries
            elsif calculator.ceremony_country == 'gibraltar'
              outcome :outcome_same_sex_marriage_and_civil_partnership_in_gibraltar
            elsif calculator.ceremony_country == 'greece'
              outcome :outcome_same_sex_civil_partnership_in_greece
            else
              outcome :outcome_same_sex_marriage_and_civil_partnership_not_possible
            end
          end
        end
      end

      outcome :outcome_ceremonies_in_denmark_when_residing_in_uk_or_denmark
      outcome :outcome_ceremonies_in_ireland
      outcome :outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries
      outcome :outcome_ceremonies_in_portugal
      outcome :outcome_ceremonies_in_spain
      outcome :outcome_ceremonies_in_sweden_when_residing_in_sweden
      outcome :outcome_ceremonies_in_switzerland
      outcome :outcome_civil_partnership_in_france_or_french_overseas_territory
      outcome :outcome_civil_partnership_in_monaco
      outcome :outcome_marriage_in_brazil_when_residing_in_brazil
      outcome :outcome_marriage_in_brazil_when_residing_in_third_country
      outcome :outcome_marriage_in_france_or_french_overseas_territory
      outcome :outcome_marriage_in_monaco
      outcome :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
      outcome :outcome_opposite_sex_marriage_in_affirmation_countries
      outcome :outcome_opposite_sex_marriage_in_belarus
      outcome :outcome_opposite_sex_marriage_in_belgium
      outcome :outcome_opposite_sex_marriage_in_british_indian_ocean_territory
      outcome :outcome_opposite_sex_marriage_in_british_overseas_territory
      outcome :outcome_opposite_sex_marriage_in_british_virgin_islands
      outcome :outcome_opposite_sex_marriage_in_bulgaria_when_residing_in_bulgaria_or_third_country
      outcome :outcome_opposite_sex_marriage_in_bulgaria_when_residing_in_uk
      outcome :outcome_opposite_sex_marriage_in_burma
      outcome :outcome_opposite_sex_marriage_in_cambodia
      outcome :outcome_opposite_sex_marriage_in_china
      outcome :outcome_opposite_sex_marriage_in_colombia
      outcome :outcome_opposite_sex_marriage_in_commonwealth_countries
      outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
      outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
      outcome :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
      outcome :outcome_opposite_sex_marriage_in_dominican_republic
      outcome :outcome_opposite_sex_marriage_in_ecuador
      outcome :outcome_opposite_sex_marriage_in_egypt
      outcome :outcome_opposite_sex_marriage_in_germany_when_residing_in_germany_or_third_country
      outcome :outcome_opposite_sex_marriage_in_germany_when_residing_in_the_uk
      outcome :outcome_opposite_sex_marriage_in_georgia
      outcome :outcome_opposite_sex_marriage_in_hong_kong
      outcome :outcome_opposite_sex_marriage_in_indonesia
      outcome :outcome_opposite_sex_marriage_in_italy_when_residing_in_italy
      outcome :outcome_opposite_sex_marriage_in_italy_when_residing_in_uk
      outcome :outcome_opposite_sex_marriage_in_japan
      outcome :outcome_same_sex_for_non_romanians
      outcome :outcome_opposite_sex_marriage_in_kosovo_when_residing_in_kosovo
      outcome :outcome_opposite_sex_marriage_in_kosovo_when_residing_in_uk
      outcome :outcome_opposite_sex_marriage_in_kuwait_when_residing_in_third_country
      outcome :outcome_opposite_sex_marriage_in_kuwait_when_residing_in_kuwait
      outcome :outcome_opposite_sex_marriage_in_kuwait_when_residing_in_uk
      outcome :outcome_opposite_sex_marriage_in_laos_with_lao_national
      outcome :outcome_opposite_sex_marriage_in_laos_without_lao_national
      outcome :outcome_opposite_sex_marriage_in_macao
      outcome :outcome_opposite_sex_marriage_in_morocco
      outcome :outcome_opposite_sex_marriage_in_north_korea
      outcome :outcome_opposite_sex_marriage_in_norway
      outcome :outcome_same_sex_marriage_in_italy
      outcome :outcome_opposite_sex_marriage_in_oman
      outcome :outcome_opposite_sex_marriage_in_other_countries
      outcome :outcome_opposite_sex_marriage_in_peru
      outcome :outcome_opposite_sex_marriage_in_philippines
      outcome :outcome_opposite_sex_marriage_in_poland_when_residing_in_poland
      outcome :outcome_opposite_sex_marriage_in_poland_when_residing_in_uk
      outcome :outcome_opposite_sex_marriage_in_qatar
      outcome :outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_uk_or_third_country
      outcome :outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_saudi_arabia
      outcome :outcome_opposite_sex_marriage_in_slovenia_when_residing_in_uk_or_slovenia
      outcome :outcome_opposite_sex_marriage_in_south_korea
      outcome :outcome_opposite_sex_marriage_in_slovakia
      outcome :outcome_opposite_sex_marriage_in_thailand
      outcome :outcome_opposite_sex_marriage_in_turkey
      outcome :outcome_opposite_sex_marriage_in_united_arab_emirates
      outcome :outcome_opposite_sex_marriage_in_vietnam
      outcome :outcome_opposite_sex_marriage_in_yemen
      outcome :outcome_same_sex_civil_partnership
      outcome :outcome_same_sex_civil_partnership_in_affirmation_countries
      outcome :outcome_same_sex_civil_partnership_in_commonwealth_countries
      outcome :outcome_same_sex_civil_partnership_in_consular_countries
      outcome :outcome_same_sex_civil_partnership_in_no_cni_countries
      outcome :outcome_same_sex_marriage_and_civil_partnership
      outcome :outcome_same_sex_marriage_and_civil_partnership_in_gibraltar
      outcome :outcome_same_sex_marriage_and_civil_partnership_in_japan
      outcome :outcome_same_sex_marriage_and_civil_partnership_in_malta
      outcome :outcome_opposite_same_sex_marriage_residing_in_uk_or_south_africa
      outcome :outcome_same_sex_marriage_and_civil_partnership_not_possible
      outcome :outcome_same_sex_marriage_in_dominican_republic
      outcome :outcome_same_sex_civil_partnership_in_greece
      outcome :country
    end
  end
end
