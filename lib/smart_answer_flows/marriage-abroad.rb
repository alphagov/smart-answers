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
        next_node_calculation :calculator do
          Calculators::MarriageAbroadCalculator.new
        end

        next_node do |response|
          calculator.ceremony_country = response
          if calculator.ceremony_country == 'ireland'
            question :partner_opposite_or_same_sex?
          elsif %w(france monaco new-caledonia wallis-and-futuna).include?(calculator.ceremony_country)
            question :marriage_or_pacs?
          elsif calculator.ceremony_country_is_french_overseas_territory?
            outcome :outcome_os_france_or_fot
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

        next_node do |response|
          calculator.resident_of = response
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

        next_node do |response|
          calculator.marriage_or_pacs = response
          if calculator.ceremony_country == 'monaco'
            outcome :outcome_monaco
          elsif calculator.want_to_get_married?
            outcome :outcome_os_france_or_fot
          else
            outcome :outcome_cp_france_pacs
          end
        end
      end

      # Q4
      multiple_choice :what_is_your_partners_nationality? do
        option :partner_british
        option :partner_local
        option :partner_other

        next_node do |response|
          calculator.partner_nationality = response
          question :partner_opposite_or_same_sex?
        end
      end

      # Q5
      multiple_choice :partner_opposite_or_same_sex? do
        option :opposite_sex
        option :same_sex

        next_node do |response|
          calculator.sex_of_your_partner = response
          if calculator.ceremony_country == 'brazil' && calculator.resident_outside_of_uk?
            outcome :outcome_brazil_not_living_in_the_uk
          elsif calculator.ceremony_country == "netherlands"
            outcome :outcome_marriage_via_local_authorities
          elsif calculator.ceremony_country == "portugal"
            outcome :outcome_portugal
          elsif calculator.ceremony_country == "ireland"
            outcome :outcome_ireland
          elsif calculator.ceremony_country == "switzerland"
            outcome :outcome_switzerland
          elsif calculator.ceremony_country == "spain"
            outcome :outcome_spain
          elsif calculator.ceremony_country == 'dominican-republic'
            outcome :outcome_dominican_republic
          elsif calculator.partner_is_opposite_sex?
            if calculator.ceremony_country == 'hong-kong'
              outcome :outcome_os_hong_kong
            elsif calculator.ceremony_country == 'germany'
              outcome :outcome_os_germany
            elsif calculator.ceremony_country == 'oman'
              outcome :outcome_os_oman
            elsif calculator.ceremony_country == 'belarus'
              outcome :outcome_os_belarus
            elsif calculator.ceremony_country == 'kuwait'
              outcome :outcome_os_kuwait
            elsif calculator.ceremony_country == 'japan'
              outcome :outcome_os_japan
            elsif calculator.resident_of_third_country? &&
                (
                  calculator.opposite_sex_consular_cni_country? ||
                  %w(kosovo).include?(calculator.ceremony_country) ||
                  calculator.opposite_sex_consular_cni_in_nearby_country?
                )
              outcome :outcome_consular_cni_os_residing_in_third_country
            elsif calculator.ceremony_country == 'norway' && calculator.resident_of_third_country?
              outcome :outcome_consular_cni_os_residing_in_third_country
            elsif calculator.ceremony_country == 'italy'
              outcome :outcome_os_italy
            elsif calculator.ceremony_country == 'cambodia'
              outcome :outcome_os_cambodia
            elsif calculator.ceremony_country == "colombia"
              outcome :outcome_os_colombia
            elsif calculator.ceremony_country == 'germany'
              outcome :outcome_os_germany
            elsif calculator.ceremony_country == "kosovo"
              outcome :outcome_os_kosovo
            elsif calculator.ceremony_country == "indonesia"
              outcome :outcome_os_indonesia
            elsif calculator.ceremony_country == "laos" && calculator.partner_is_not_national_of_ceremony_country?
              outcome :outcome_os_marriage_impossible_no_laos_locals
            elsif calculator.ceremony_country == "laos"
              outcome :outcome_os_laos
            elsif calculator.ceremony_country == 'poland'
              outcome :outcome_os_poland
            elsif calculator.ceremony_country == 'slovenia'
              outcome :outcome_os_slovenia
            elsif calculator.opposite_sex_consular_cni_country? ||
                (
                  calculator.resident_of_uk? &&
                  calculator.opposite_sex_no_marriage_related_consular_services_in_ceremony_country?
                ) ||
                calculator.opposite_sex_consular_cni_in_nearby_country?
              outcome :outcome_os_consular_cni
            elsif calculator.ceremony_country == "finland" && calculator.resident_of_uk?
              outcome :outcome_os_consular_cni
            elsif calculator.ceremony_country == "norway" && calculator.resident_of_uk?
              outcome :outcome_os_consular_cni
            elsif calculator.opposite_sex_affirmation_country?
              outcome :outcome_os_affirmation
            elsif calculator.ceremony_country_in_the_commonwealth? ||
                calculator.ceremony_country == 'zimbabwe'
              outcome :outcome_os_commonwealth
            elsif calculator.ceremony_country_is_british_overseas_territory?
              outcome :outcome_os_bot
            elsif calculator.opposite_sex_no_consular_cni_country? ||
                (
                  calculator.resident_outside_of_uk? &&
                  calculator.opposite_sex_no_marriage_related_consular_services_in_ceremony_country?
                )
              outcome :outcome_os_no_cni
            elsif calculator.opposite_sex_marriage_via_local_authorities?
              outcome :outcome_marriage_via_local_authorities
            elsif calculator.opposite_sex_in_other_countries?
              outcome :outcome_os_other_countries
            end
          elsif calculator.partner_is_same_sex?
            if %w(belgium norway).include?(calculator.ceremony_country)
              outcome :outcome_ss_affirmation
            elsif calculator.same_sex_ceremony_country_unknown_or_has_no_embassies?
              outcome :outcome_os_no_cni
            elsif calculator.ceremony_country == "malta"
              outcome :outcome_ss_marriage_malta
            elsif calculator.same_sex_marriage_not_possible?
              outcome :outcome_ss_marriage_not_possible
            elsif calculator.ceremony_country == "germany" && calculator.partner_is_national_of_ceremony_country?
              outcome :outcome_cp_or_equivalent
            elsif calculator.same_sex_marriage_country? ||
                (
                  calculator.same_sex_marriage_country_when_couple_british? &&
                  calculator.partner_british?
                ) ||
                calculator.same_sex_marriage_and_civil_partnership?
              outcome :outcome_ss_marriage
            elsif calculator.civil_partnership_equivalent_country?
              outcome :outcome_cp_or_equivalent
            elsif calculator.civil_partnership_cni_not_required_country?
              outcome :outcome_cp_no_cni
            elsif %w(canada south-africa).include?(calculator.ceremony_country)
              outcome :outcome_cp_commonwealth_countries
            elsif calculator.civil_partnership_consular_country?
              outcome :outcome_cp_consular
            else
              outcome :outcome_cp_all_other_countries
            end
          end
        end
      end

      outcome :outcome_ireland

      outcome :outcome_switzerland

      outcome :outcome_marriage_via_local_authorities

      outcome :outcome_portugal

      outcome :outcome_os_germany

      outcome :outcome_os_kuwait

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

      outcome :outcome_spain

      outcome :outcome_os_commonwealth

      outcome :outcome_os_bot

      outcome :outcome_os_belarus

      outcome :outcome_os_italy

      outcome :outcome_consular_cni_os_residing_in_third_country

      outcome :outcome_os_consular_cni

      outcome :outcome_os_france_or_fot

      outcome :outcome_os_affirmation

      outcome :outcome_os_no_cni

      outcome :outcome_os_other_countries

      #CP outcomes
      outcome :outcome_cp_or_equivalent

      outcome :outcome_cp_france_pacs

      outcome :outcome_cp_no_cni

      outcome :outcome_cp_commonwealth_countries

      outcome :outcome_cp_consular

      outcome :outcome_cp_all_other_countries

      outcome :outcome_ss_marriage

      outcome :outcome_ss_marriage_not_possible

      outcome :outcome_ss_marriage_malta

      outcome :outcome_ss_affirmation

      outcome :outcome_os_marriage_impossible_no_laos_locals

      outcome :outcome_dominican_republic
    end
  end
end
