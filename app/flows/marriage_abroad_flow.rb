# Abbreviations used in this smart answer:
# CNI - Certificate of No Impediment
# CI - Channel Islands
# CP - Civil Partnership
# FCO - Foreign & Commonwealth Office
# IOM - Isle Of Man
# OS - Opposite Sex
# SS - Same Sex
class MarriageAbroadFlow < SmartAnswer::Flow
  def define
    content_id "d0a95767-f6ab-432a-aebc-096e37fb3039"
    name "marriage-abroad"
    status :published

    exclude_countries = %w[samoa mali holy-see british-antarctic-territory the-occupied-palestinian-territories]

    # Q1
    country_select :country_of_ceremony?, exclude_countries: exclude_countries do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::MarriageAbroadCalculator.new
        calculator.ceremony_country = response
      end

      validate do
        calculator.valid_ceremony_country?
      end

      next_node do
        if calculator.one_question_country?
          outcome :outcome_marriage_abroad_in_country
        elsif calculator.two_questions_country?
          question :partner_opposite_or_same_sex?
        elsif calculator.ceremony_country_offers_pacs?
          question :marriage_or_pacs?
        elsif calculator.ceremony_country_is_french_overseas_territory?
          outcome :outcome_marriage_abroad_in_country
        else
          question :legal_residency?
        end
      end
    end

    # Q2
    radio :legal_residency? do
      option :uk
      option :ceremony_country
      option :third_country

      on_response do |response|
        calculator.resident_of = response
      end

      next_node do
        if calculator.outcome_ceremony_location_country?
          outcome :outcome_marriage_abroad_in_country
        elsif calculator.three_questions_country?
          question :partner_opposite_or_same_sex?
        else
          question :what_is_your_partners_nationality?
        end
      end
    end

    # Q3a
    radio :marriage_or_pacs? do
      option :marriage
      option :pacs

      on_response do |response|
        calculator.marriage_or_pacs = response
      end

      next_node do
        outcome :outcome_marriage_abroad_in_country
      end
    end

    # Q4
    radio :what_is_your_partners_nationality? do
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
    radio :partner_opposite_or_same_sex? do
      option :opposite_sex
      option :same_sex

      on_response do |response|
        calculator.sex_of_your_partner = response
      end

      next_node do |response|
        if calculator.offers_consular_opposite_sex_civil_partnership? && response == "opposite_sex"
          if calculator.ceremony_country == "vietnam" && calculator.partner_nationality == "partner_local"
            outcome :outcome_marriage_abroad_in_country
          else
            question :marriage_or_civil_partnership?
          end
        elsif calculator.has_outcome_per_path?
          outcome :outcome_marriage_abroad_in_country
        end
      end
    end

    # Q6
    radio :marriage_or_civil_partnership? do
      option :marriage
      option :civil_partnership

      on_response do |response|
        calculator.type_of_ceremony = response
      end

      next_node do
        outcome :outcome_marriage_abroad_in_country
      end
    end

    outcome :outcome_marriage_abroad_in_country
  end
end
