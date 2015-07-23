module SmartAnswer
  class RegisterABirthFlow < Flow
    def define
      name 'register-a-birth'
      status :published
      satisfies_need "101003"

      country_name_query = SmartAnswer::Calculators::CountryNameFormatter.new
      reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
      translator_query = SmartAnswer::Calculators::TranslatorLinks.new
      country_has_no_embassy = SmartAnswer::Predicate::RespondedWith.new(%w(iran syria yemen))
      exclude_countries = %w(holy-see british-antarctic-territory)

      # Q1
      country_select :country_of_birth?, exclude_countries: exclude_countries do
        save_input_as :country_of_birth

        calculate :registration_country do |response|
          reg_data_query.registration_country_slug(response)
        end

        calculate :registration_country_name_lowercase_prefix do
          country_name_query.definitive_article(registration_country)
        end

        next_node_if(:no_embassy_result, country_has_no_embassy)
        next_node_if(:commonwealth_result, reg_data_query.responded_with_commonwealth_country?)
        next_node(:who_has_british_nationality?)
      end

      # Q2
      multiple_choice :who_has_british_nationality? do
        option mother: :married_couple_or_civil_partnership?
        option father: :married_couple_or_civil_partnership?
        option mother_and_father: :married_couple_or_civil_partnership?
        option neither: :no_registration_result

        save_input_as :british_national_parent
      end

      # Q3
      multiple_choice :married_couple_or_civil_partnership? do
        option :yes
        option :no

        calculate :paternity_declaration do |response|
          response == 'no'
        end

        next_node_if(:childs_date_of_birth?, responded_with('no'), variable_matches(:british_national_parent, 'father'))
        next_node(:where_are_you_now?)
      end

      # Q4
      date_question :childs_date_of_birth? do
        from { Date.today.end_of_year }
        to { 50.years.ago(Date.today) }

        before_july_2006 = SmartAnswer::Predicate::Callable.new("before 1 July 2006") do |response|
          Date.new(2006, 07, 01) > response
        end

        next_node_if(:homeoffice_result, before_july_2006)

        next_node(:where_are_you_now?)
      end

      # Q5
      multiple_choice :where_are_you_now? do
        option :same_country
        option :another_country
        option :in_the_uk

        calculate :same_country do |response|
          response == 'same_country'
        end

        calculate :another_country do |response|
          response == 'another_country'
        end

        calculate :in_the_uk do |response|
          response == 'in_the_uk'
        end

        define_predicate(:no_birth_certificate_exception) {
          reg_data_query.has_birth_registration_exception?(country_of_birth) & paternity_declaration
        }

        define_predicate(:born_in_north_korea) {
          country_of_birth == 'north-korea'
        }

        next_node_if(:no_birth_certificate_result, no_birth_certificate_exception)
        next_node_if(:which_country?, responded_with('another_country'))
        on_condition(responded_with('same_country')) do
          next_node_if(:north_korea_result, born_in_north_korea)
        end
        next_node(:oru_result)
      end

      # Q6
      country_select :which_country?, exclude_countries: exclude_countries do
        calculate :registration_country do |response|
          reg_data_query.registration_country_slug(response)
        end

        calculate :registration_country_name_lowercase_prefix do
          country_name_query.definitive_article(registration_country)
        end

        define_predicate(:currently_in_north_korea) {
          response == 'north-korea'
        }

        next_node_if(:north_korea_result, currently_in_north_korea)
        next_node(:oru_result)
      end

      # Outcomes

      use_outcome_templates

      outcome :north_korea_result do
        precalculate :reg_data_query do
          reg_data_query
        end

        precalculate :checklist_countries do
          %w(bangladesh kuwait libya north-korea pakistan philippines turkey)
        end

        precalculate :postal_form_url do
          reg_data_query.postal_form(registration_country)
        end

        precalculate :postal_return_form_url do
          reg_data_query.postal_return_form(registration_country)
        end

        precalculate :location do
          loc = WorldLocation.find(registration_country)
          raise InvalidResponse unless loc
          loc
        end

        precalculate :organisations do
          [location.fco_organisation]
        end

        precalculate :overseas_passports_embassies do
          if organisations and organisations.any?
            service_title = 'Births and Deaths registration service'
            organisations.first.offices_with_service(service_title)
          else
            []
          end
        end
      end

      outcome :oru_result do
        precalculate :reg_data_query do
          reg_data_query
        end

        precalculate :document_return_fees do
          reg_data_query.document_return_fees
        end

        precalculate :button_data do
          {text: "Pay now", url: "https://pay-register-birth-abroad.service.gov.uk/start"}
        end

        precalculate :custom_waiting_time do
          reg_data_query.custom_registration_duration(country_of_birth)
        end

        precalculate :born_in_lower_risk_country do
          reg_data_query.class::HIGHER_RISK_COUNTRIES.exclude?(country_of_birth)
        end

        precalculate :location do
          loc = WorldLocation.find(registration_country)
          raise InvalidResponse unless loc
          loc
        end

        precalculate :organisations do
          [location.fco_organisation]
        end

        precalculate :overseas_passports_embassies do
          if organisations and organisations.any?
            service_title = 'Births and Deaths registration service'
            organisations.first.offices_with_service(service_title)
          else
            []
          end
        end

        precalculate :translator_link_url do
          translator_query.links[country_of_birth]
        end
      end

      outcome :commonwealth_result
      outcome :no_registration_result
      outcome :no_embassy_result
      outcome :homeoffice_result
      outcome :no_birth_certificate_result do

        precalculate :location do
          loc = WorldLocation.find(country_of_birth)
          raise InvalidResponse unless loc
          loc
        end

        precalculate :organisations do
          [location.fco_organisation]
        end

        precalculate :overseas_passports_embassies do
          if organisations and organisations.any?
            service_title = 'Births and Deaths registration service'
            organisations.first.offices_with_service(service_title)
          else
            []
          end
        end
      end
    end
  end
end
