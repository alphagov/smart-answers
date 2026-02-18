class CheckUkVisaFlow < SmartAnswer::Flow
  def define
    flow = self
    content_id "dc1a1744-4089-43b3-b2e3-4e397b6b15b1"
    name "check-uk-visa"
    status :published

    additional_countries = UkbaCountry.all

    # Q1
    country_select :what_passport_do_you_have?, additional_countries:, exclude_countries: SmartAnswer::Calculators::UkVisaCalculator::EXCLUDE_COUNTRIES do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::UkVisaCalculator.new
        calculator.passport_country = response
        self.purpose_of_visit_answer = nil
      end

      next_node do
        question :dual_british_or_irish_citizenship?
      end
    end

    # Q2
    radio :dual_british_or_irish_citizenship? do
      option :yes
      option :no
      option :dont_know

      next_node do |response|
        if %w[yes dont_know].include?(response)
          outcome :outcome_no_visa_or_eta_for_british_or_irish_dual_citizens
        elsif calculator.passport_country_is_israel?
          question :israeli_document_type?
        elsif calculator.passport_country_is_estonia?
          question :what_sort_of_passport?
        elsif calculator.passport_country_is_latvia?
          question :what_sort_of_passport?
        elsif calculator.passport_country_is_hong_kong?
          question :what_sort_of_travel_document?
        elsif calculator.passport_country_is_macao?
          question :what_sort_of_travel_document?
        elsif calculator.passport_country_is_ireland?
          outcome :outcome_no_visa_needed_ireland
        else
          question :purpose_of_visit?
        end
      end
    end

    # Q2b
    radio :israeli_document_type? do
      option :"full-passport"
      option :"provisional-passport"

      on_response do |response|
        calculator.passport_country = "israel-provisional-passport" if response == "provisional-passport"
      end

      next_node do
        question :purpose_of_visit?
      end
    end

    # Q2c / Q2d
    radio :what_sort_of_passport? do
      option :citizen
      option :alien

      next_node do |response|
        if response == "alien"
          if calculator.passport_country_is_estonia?
            calculator.passport_country = "estonia-alien-passport"
          elsif calculator.passport_country_is_latvia?
            calculator.passport_country = "latvia-alien-passport"
          end
        end
        question :purpose_of_visit?
      end
    end

    # Q2e / Q2f
    radio :what_sort_of_travel_document? do
      option :passport
      option :travel_document

      on_response do |response|
        calculator.travel_document_type = response
      end

      next_node do |_|
        question :purpose_of_visit?
      end
    end

    # Q3
    radio :purpose_of_visit? do
      option :tourism
      option :work
      option :study
      option :transit
      option :family
      option :marriage
      option :school
      option :medical
      option :diplomatic

      flow.travel_response_next_route(self)
    end

    # Q3a
    radio :travelling_to_cta? do
      option :channel_islands_or_isle_of_man
      option :republic_of_ireland
      option :somewhere_else

      on_response do |response|
        calculator.travelling_to_cta_answer = response
      end

      next_node do
        if calculator.travelling_to_channel_islands_or_isle_of_man?
          next question(:channel_islands_or_isle_of_man?)
        elsif calculator.travelling_to_ireland?
          if calculator.passport_country_requires_electronic_travel_authorisation?
            next outcome(:outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation)
          elsif (calculator.passport_country_in_non_visa_national_list? ||
            calculator.passport_country_in_eea? ||
            calculator.passport_country_in_british_overseas_territories_list?) &&
              !calculator.travel_document?
            next outcome(:outcome_no_visa_needed)
          else
            next outcome(:outcome_transit_to_the_republic_of_ireland)
          end
        elsif calculator.travelling_to_elsewhere?
          if (calculator.passport_country_in_non_visa_national_list? ||
              calculator.passport_country_in_eea? ||
              calculator.passport_country_in_british_overseas_territories_list?) &&
              !calculator.travel_document?
            next outcome(:outcome_no_visa_needed)
          else
            next question(:passing_through_uk_border_control?)
          end
        end
      end
    end

    # Q3b
    radio :channel_islands_or_isle_of_man? do
      option :tourism
      option :work
      option :study
      option :family
      option :marriage
      option :school
      option :medical
      option :diplomatic

      flow.travel_response_next_route(self)
    end

    # Q4
    radio :passing_through_uk_border_control? do
      option :yes
      option :no

      on_response do |response|
        calculator.passing_through_uk_border_control_answer = response
      end

      next_node do
        if calculator.passing_through_uk_border_control?
          if calculator.passport_country_is_taiwan?
            outcome :outcome_transit_taiwan_through_border_control
          elsif calculator.passport_country_in_visa_national_list? ||
              calculator.travel_document?
            outcome :outcome_transit_leaving_airport
          elsif calculator.passport_country_in_direct_airside_transit_visa_list?
            outcome :outcome_transit_leaving_airport_direct_airside_transit_visa
          end
        elsif calculator.passport_country_is_taiwan?
          outcome :outcome_transit_taiwan
        elsif calculator.passport_country_is_venezuela?
          outcome :outcome_no_visa_needed
        elsif calculator.applicant_is_stateless_or_a_refugee?
          outcome :outcome_transit_refugee_not_leaving_airport
        elsif calculator.passport_country_in_direct_airside_transit_visa_list?
          outcome :outcome_transit_not_leaving_airport
        elsif calculator.passport_country_in_visa_national_list? ||
            calculator.travel_document?
          outcome :outcome_no_visa_needed
        end
      end
    end

    # Q5
    radio :staying_for_how_long? do
      option :six_months_or_less
      option :longer_than_six_months

      on_response do |response|
        calculator.length_of_stay = response
      end

      next_node do
        if calculator.staying_for_over_six_months?
          if calculator.study_visit?
            outcome :outcome_study_y # outcome 2 study y
          elsif calculator.work_visit?
            question :what_type_of_work?
          end
        elsif calculator.staying_for_six_months_or_less?
          if calculator.study_visit?
            if calculator.passport_country_requires_electronic_travel_authorisation?
              outcome :outcome_study_electronic_travel_authorisation
            elsif calculator.passport_country_is_taiwan?
              outcome :outcome_study_waiver_taiwan
            elsif calculator.passport_country_in_direct_airside_transit_visa_list? ||
                calculator.passport_country_in_visa_national_list? ||
                calculator.travel_document?
              outcome :outcome_study_m # outcome 3 study m visa needed short courses
            elsif calculator.passport_country_in_british_overseas_territories_list? || calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_eea?
              outcome :outcome_study_no_visa_needed # outcome 1 no visa needed
            end
          elsif calculator.work_visit?
            if calculator.passport_country_requires_electronic_travel_authorisation?
              outcome :outcome_work_electronic_travel_authorisation
            elsif (calculator.passport_country_in_british_overseas_territories_list? ||
                calculator.passport_country_is_taiwan? ||
                calculator.passport_country_in_non_visa_national_list? ||
                calculator.passport_country_in_eea?) &&
                !calculator.travel_document?
              # outcome 5.5 work N no visa needed
              outcome :outcome_work_n
            else
              # outcome 5 work m visa needed short courses
              outcome :outcome_work_m
            end
          end
        end
      end
    end

    # Q6
    radio :travelling_visiting_partner_family_member? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          outcome :outcome_tourism_visa_partner
        else
          outcome :outcome_standard_visitor_visa
        end
      end
    end

    # Q7
    radio :partner_family_british_citizen? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          outcome :outcome_partner_family_british_citizen_y
        else
          question :partner_family_eea?
        end
      end
    end

    # Q8
    radio :partner_family_eea? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          outcome :outcome_partner_family_eea_y
        else
          outcome :outcome_partner_family_eea_n
        end
      end
    end

    # Q9
    radio :what_type_of_work? do
      option :health
      option :digital
      option :academic
      option :arts
      option :sports
      option :religious
      option :business
      option :other

      next_node do |response|
        calculator.what_type_of_work = response
        outcome :outcome_work_y
      end
    end

    outcome :outcome_diplomatic_business
    outcome :outcome_joining_family_nvn
    outcome :outcome_marriage_nvn
    outcome :outcome_marriage_taiwan
    outcome :outcome_marriage_visa_nat_direct_airside_transit_visa
    outcome :outcome_medical_n
    outcome :outcome_medical_y
    outcome :outcome_no_visa_needed
    outcome :outcome_no_visa_needed_ireland
    outcome :outcome_no_visa_or_eta_for_british_or_irish_dual_citizens
    outcome :outcome_partner_family_british_citizen_y
    outcome :outcome_partner_family_eea_y
    outcome :outcome_partner_family_eea_n
    outcome :outcome_school_n
    outcome :outcome_school_electronic_travel_authorisation
    outcome :outcome_school_y
    outcome :outcome_standard_visitor_visa
    outcome :outcome_study_m
    outcome :outcome_study_electronic_travel_authorisation
    outcome :outcome_study_waiver_taiwan
    outcome :outcome_study_no_visa_needed
    outcome :outcome_study_y
    outcome :outcome_transit_leaving_airport
    outcome :outcome_transit_leaving_airport_direct_airside_transit_visa
    outcome :outcome_transit_not_leaving_airport
    outcome :outcome_transit_refugee_not_leaving_airport
    outcome :outcome_transit_taiwan
    outcome :outcome_transit_taiwan_through_border_control
    outcome :outcome_transit_to_the_republic_of_ireland
    outcome :outcome_transit_to_the_republic_of_ireland_electronic_travel_authorisation
    outcome :outcome_tourism_n
    outcome :outcome_tourism_visa_partner
    outcome :outcome_medical_electronic_travel_authorisation
    outcome :outcome_tourism_electronic_travel_authorisation
    outcome :outcome_visit_waiver_taiwan
    outcome :outcome_work_m
    outcome :outcome_work_n
    outcome :outcome_work_electronic_travel_authorisation
    outcome :outcome_work_y
  end

  def travel_response_next_route(node)
    node.on_response do |response|
      calculator.purpose_of_visit_answer = response
    end

    node.next_node do
      if calculator.study_visit? || calculator.work_visit?
        next question(:staying_for_how_long?)
      end

      if calculator.diplomatic_visit?
        next outcome(:outcome_diplomatic_business)
      end

      if calculator.school_visit?
        if calculator.passport_country_requires_electronic_travel_authorisation?
          next outcome(:outcome_school_electronic_travel_authorisation)
        elsif calculator.passport_country_is_taiwan?
          next outcome(:outcome_study_waiver_taiwan)
        elsif calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_british_overseas_territories_list? || calculator.passport_country_in_eea?
          next outcome(:outcome_school_n)
        else
          next outcome(:outcome_school_y)
        end
      end

      if calculator.medical_visit?
        if calculator.passport_country_requires_electronic_travel_authorisation?
          next outcome(:outcome_medical_electronic_travel_authorisation)
        elsif calculator.passport_country_is_taiwan?
          next outcome(:outcome_visit_waiver_taiwan)
        elsif (calculator.passport_country_in_non_visa_national_list? ||
            calculator.passport_country_in_eea? ||
            calculator.passport_country_in_british_overseas_territories_list?) &&
            !calculator.travel_document?
          next outcome(:outcome_medical_n)
        else
          next outcome(:outcome_medical_y)
        end
      end

      if calculator.tourism_visit?
        if calculator.passport_country_requires_electronic_travel_authorisation?
          next outcome(:outcome_tourism_electronic_travel_authorisation)
        elsif calculator.passport_country_is_taiwan?
          next outcome(:outcome_visit_waiver_taiwan)
        elsif (calculator.passport_country_in_non_visa_national_list? ||
            calculator.passport_country_in_eea? ||
            calculator.passport_country_in_british_overseas_territories_list?) &&
            !calculator.travel_document?
          next outcome(:outcome_tourism_n)
        else
          next question(:travelling_visiting_partner_family_member?)
        end
      end

      if calculator.marriage_visit?
        if calculator.passport_country_in_eea? || calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_british_overseas_territories_list?
          next outcome(:outcome_marriage_nvn)
        elsif calculator.passport_country_is_taiwan?
          next outcome(:outcome_marriage_taiwan)
        elsif calculator.passport_country_in_direct_airside_transit_visa_list? || calculator.passport_country_in_visa_national_list?
          next outcome(:outcome_marriage_visa_nat_direct_airside_transit_visa)
        end
      end

      if calculator.transit_visit?
        next question(:travelling_to_cta?)
      end

      if calculator.family_visit?
        if calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_eea? || calculator.passport_country_in_british_overseas_territories_list?
          next outcome(:outcome_joining_family_nvn)
        else
          next question(:partner_family_british_citizen?)
        end
      end
    end
  end
end
