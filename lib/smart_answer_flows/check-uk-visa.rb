module SmartAnswer
  class CheckUkVisaFlow < Flow
    def define
      content_id "dc1a1744-4089-43b3-b2e3-4e397b6b15b1"
      name 'check-uk-visa'
      status :published
      satisfies_need "100982"

      additional_countries = UkbaCountry.all

      # Q1
      country_select :what_passport_do_you_have?, additional_countries: additional_countries, exclude_countries: Calculators::UkVisaCalculator::EXCLUDE_COUNTRIES do
        on_response do |response|
          self.calculator = Calculators::UkVisaCalculator.new
          calculator.passport_country = response
        end

        calculate :purpose_of_visit_answer do
          nil
        end

        next_node do
          if calculator.passport_country_is_israel?
            question :israeli_document_type?
          elsif calculator.passport_country_in_eea?
            outcome :outcome_no_visa_needed
          else
            question :purpose_of_visit?
          end
        end
      end

      # Q1b
      multiple_choice :israeli_document_type? do
        option :"full-passport"
        option :"provisional-passport"

        on_response do |response|
          calculator.passport_country = 'israel-provisional-passport' if response == 'provisional-passport'
        end

        next_node do
          question :purpose_of_visit?
        end
      end

      # Q2
      multiple_choice :purpose_of_visit? do
        option :tourism
        option :work
        option :study
        option :transit
        option :family
        option :marriage
        option :school
        option :medical
        option :diplomatic

        on_response do |response|
          calculator.purpose_of_visit_answer = response
        end

        next_node do
          if calculator.study_visit? || calculator.work_visit?
            next question(:staying_for_how_long?)
          end

          if calculator.diplomatic_visit?
            next outcome(:outcome_diplomatic_business)
          end

          if calculator.school_visit?
            if calculator.passport_country_in_electronic_visa_waiver_list?
              next outcome(:outcome_school_waiver)
            elsif calculator.passport_country_is_taiwan?
              next outcome(:outcome_taiwan_exception)
            elsif calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_ukot_list?
              next outcome(:outcome_school_n)
            else
              next outcome(:outcome_school_y)
            end
          end

          if calculator.medical_visit?
            if calculator.passport_country_in_electronic_visa_waiver_list?
              next outcome(:outcome_visit_waiver)
            elsif calculator.passport_country_is_taiwan?
              next outcome(:outcome_taiwan_exception)
            elsif calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_ukot_list?
              next outcome(:outcome_medical_n)
            else
              next outcome(:outcome_medical_y)
            end
          end

          if calculator.tourism_visit?
            if calculator.passport_country_in_electronic_visa_waiver_list?
              next outcome(:outcome_visit_waiver)
            elsif calculator.passport_country_is_taiwan?
              next outcome(:outcome_taiwan_exception)
            elsif calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_ukot_list?
              next outcome(:outcome_school_n) # outcome does not contain school specific content
            else
              next outcome(:outcome_standard_visit)
            end
          end

          if calculator.marriage_visit?
            next outcome(:outcome_marriage)
          end

          if calculator.transit_visit?
            if calculator.passport_country_in_datv_list? ||
                calculator.passport_country_in_visa_national_list? || calculator.passport_country_is_taiwan? || calculator.passport_country_is_venezuela?
              next question(:passing_through_uk_border_control?)
            else
              next outcome(:outcome_no_visa_needed)
            end
          end

          if calculator.family_visit?
            if calculator.passport_country_in_ukot_list?
              next outcome(:outcome_joining_family_m)
            elsif calculator.passport_country_in_non_visa_national_list?
              next outcome(:outcome_joining_family_nvn)
            else
              next outcome(:outcome_joining_family_y)
            end
          end
        end
      end

      #Q3
      multiple_choice :passing_through_uk_border_control? do
        option :yes
        option :no

        on_response do |response|
          calculator.passing_through_uk_border_control_answer = response
        end

        next_node do
          if calculator.passing_through_uk_border_control?
            if calculator.passport_country_is_taiwan?
              outcome :outcome_transit_taiwan_through_border_control
            elsif calculator.passport_country_in_visa_national_list?
              outcome :outcome_transit_leaving_airport
            elsif calculator.passport_country_in_datv_list?
              outcome :outcome_transit_leaving_airport_datv
            end
          else
            if calculator.passport_country_is_taiwan?
              outcome :outcome_transit_taiwan
            elsif calculator.passport_country_is_venezuela?
              outcome :outcome_transit_venezuela
            elsif calculator.applicant_is_stateless_or_a_refugee?
              outcome :outcome_transit_refugee_not_leaving_airport
            elsif calculator.passport_country_in_datv_list?
              outcome :outcome_transit_not_leaving_airport
            elsif calculator.passport_country_in_visa_national_list?
              outcome :outcome_no_visa_needed
            end
          end
        end
      end

      #Q4
      multiple_choice :staying_for_how_long? do
        option :six_months_or_less
        option :longer_than_six_months

        precalculate :study_or_work do
          if calculator.study_visit?
            'study'
          elsif calculator.work_visit?
            'work'
          end
        end

        next_node do |response|
          case response
          when 'longer_than_six_months'
            if calculator.study_visit?
              outcome :outcome_study_y #outcome 2 study y
            elsif calculator.work_visit?
              outcome :outcome_work_y #outcome 4 work y
            end
          when 'six_months_or_less'
            if calculator.study_visit?
              if calculator.passport_country_in_electronic_visa_waiver_list?
                outcome :outcome_study_waiver
              elsif calculator.passport_country_is_taiwan?
                outcome :outcome_taiwan_exception
              elsif calculator.passport_country_in_datv_list? || calculator.passport_country_in_visa_national_list?
                outcome :outcome_study_m #outcome 3 study m visa needed short courses
              elsif calculator.passport_country_in_ukot_list? || calculator.passport_country_in_non_visa_national_list?
                outcome :outcome_no_visa_needed #outcome 1 no visa needed
              end
            elsif calculator.work_visit?
              if calculator.passport_country_in_electronic_visa_waiver_list?
                outcome :outcome_work_waiver
              elsif calculator.passport_country_in_ukot_list? ||
                  calculator.passport_country_is_taiwan? || calculator.passport_country_in_non_visa_national_list?
                #outcome 5.5 work N no visa needed
                outcome :outcome_work_n
              elsif calculator.passport_country_in_datv_list? || calculator.passport_country_in_visa_national_list?
                # outcome 5 work m visa needed short courses
                outcome :outcome_work_m
              end
            end
          end
        end
      end

      outcome :outcome_diplomatic_business
      outcome :outcome_joining_family_m
      outcome :outcome_joining_family_nvn
      outcome :outcome_joining_family_y
      outcome :outcome_marriage
      outcome :outcome_medical_n
      outcome :outcome_medical_y
      outcome :outcome_no_visa_needed
      outcome :outcome_school_n
      outcome :outcome_school_waiver
      outcome :outcome_school_y
      outcome :outcome_standard_visit
      outcome :outcome_study_m
      outcome :outcome_study_waiver
      outcome :outcome_study_y
      outcome :outcome_taiwan_exception
      outcome :outcome_transit_leaving_airport
      outcome :outcome_transit_leaving_airport_datv
      outcome :outcome_transit_not_leaving_airport
      outcome :outcome_transit_refugee_not_leaving_airport
      outcome :outcome_transit_taiwan
      outcome :outcome_transit_taiwan_through_border_control
      outcome :outcome_transit_venezuela
      outcome :outcome_visit_waiver
      outcome :outcome_work_m
      outcome :outcome_work_n
      outcome :outcome_work_waiver
      outcome :outcome_work_y
    end
  end
end
