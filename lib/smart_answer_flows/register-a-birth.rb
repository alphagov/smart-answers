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

        next_node_if(:no_birth_certificate_result, no_birth_certificate_exception)
        next_node_if(:which_country?, responded_with('another_country'))
        on_condition(->(_) { reg_data_query.class::ORU_TRANSITION_EXCEPTIONS.include?(country_of_birth) }) do
          next_node_if(:embassy_result, responded_with('same_country'))
        end
        next_node_if(:oru_result, reg_data_query.born_in_oru_transitioned_country? | responded_with('in_the_uk'))
        next_node_if(:embassy_result, responded_with('same_country'))
        next_node(:which_country?)
      end

      # Q6
      country_select :which_country?, exclude_countries: exclude_countries do
        calculate :registration_country do |response|
          reg_data_query.registration_country_slug(response)
        end

        calculate :registration_country_name_lowercase_prefix do
          country_name_query.definitive_article(registration_country)
        end

        next_node_if(:oru_result, reg_data_query.born_in_oru_transitioned_country?)
        next_node_if(:no_embassy_result, country_has_no_embassy)
        next_node(:embassy_result)
      end

      # Outcomes
      outcome :embassy_result, use_outcome_templates: true do
        precalculate :reg_data_query do
          reg_data_query
        end

        precalculate :embassy_high_commission_or_consulate do
          if reg_data_query.has_high_commission?(registration_country)
            "British high commission".html_safe
          elsif reg_data_query.has_consulate?(registration_country)
            "British consulate".html_safe
          elsif reg_data_query.has_trade_and_cultural_office?(registration_country)
            "British Trade & Cultural Office".html_safe
          elsif reg_data_query.has_consulate_general?(registration_country)
            "British consulate general".html_safe
          else
            "British embassy".html_safe
          end
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

        precalculate :button_data do
          {text: "Pay now", url: "https://pay-register-birth-abroad.service.gov.uk/start"}
        end

        precalculate :embassy_result_indonesia_british_father_paternity do
          if registration_country == 'indonesia' and british_national_parent == 'father' and paternity_declaration
            PhraseList.new(:indonesia_british_father_paternity)
          end
        end

        precalculate :oru_outcome_introduction do
          if reg_data_query.class::HIGHER_RISK_COUNTRIES.include?(registration_country)
            if registration_country == 'libya'
              PhraseList.new(:oru_outcome_higher_risk_country_currently_in_libya_introduction)
            else
              PhraseList.new(:oru_outcome_higher_risk_country_introduction)
            end
          else
            PhraseList.new(:oru_outcome_standard_introduction)
          end
        end

        precalculate :custom_waiting_time do
          reg_data_query.custom_registration_duration(country_of_birth)
        end

        precalculate :waiting_time do
          born_in_lower_risk_country = reg_data_query.class::HIGHER_RISK_COUNTRIES.exclude?(country_of_birth)
          phrases = PhraseList.new

          if country_of_birth == 'libya'
            phrases << :registration_duration_in_libya
          elsif custom_waiting_time
            phrases << :custom_registration_duration
          elsif reg_data_query.class::ORU_TRANSITION_EXCEPTIONS.include?(registration_country) and born_in_lower_risk_country
            phrases << :registration_duration_in_countries_with_an_exception
          elsif registration_country.in?(%w[papua-new-guinea cambodia]) and born_in_lower_risk_country
            phrases << :registration_can_take_3_months
          else
            phrases << :registration_takes_5_days
          end

          phrases
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

        precalculate :oru_documents_variant do
          if reg_data_query.class::ORU_DOCUMENTS_VARIANT_COUNTRIES_BIRTH.include?(country_of_birth)
            phrases = PhraseList.new
            if country_of_birth == 'united-arab-emirates' && paternity_declaration
              phrases << :oru_documents_variant_uae_not_married
            else
              phrases << :"oru_documents_variant_#{country_of_birth}"
            end
            phrases
          else
            PhraseList.new(:oru_documents)
          end
        end

        precalculate :translator_link_url do
          translator_query.links[country_of_birth]
        end

        precalculate :translator_link do
          if translator_link_url
            PhraseList.new(:approved_translator_link)
          else
            PhraseList.new(:no_translator_link)
          end
        end

        precalculate :morocco_swear_in_court do
          if country_of_birth == 'morocco' && paternity_declaration
            PhraseList.new(:swear_in_moroccan_court)
          end
        end

        precalculate :oru_address do
          phrases = PhraseList.new
          if country_of_birth == 'venezuela' && same_country
            phrases << :book_appointment_at_embassy
          else
            phrases << :send_registration_oru
            if in_the_uk
              phrases << :oru_address_uk
            else
              phrases << :oru_address_abroad
            end
          end
        end

        precalculate :oru_courier_text do
          phrases = PhraseList.new
          if reg_data_query.class::ORU_COURIER_VARIANTS.include?(registration_country) && !in_the_uk
            phrases << :"oru_courier_text_#{registration_country}"
            unless registration_country.in?(reg_data_query.class::ORU_COURIER_BY_HIGH_COMISSION)
              phrases << :oru_courier_text_common
            end
          else
            phrases << :oru_courier_text_default
          end
          phrases
        end

        precalculate :oru_extra_documents do
          if country_of_birth.in?(%w(philippines sierra-leone uganda))
            phrases = PhraseList.new(:oru_extra_documents_variant_intro)
            if country_of_birth == 'philippines' and british_national_parent.exclude?('mother')
              phrases << :oru_extra_documents_in_philippines_when_mother_not_british
            end
            phrases << :"oru_extra_documents_variant_#{country_of_birth}"
          end
        end

        precalculate :payment_method do
          if !in_the_uk && registration_country == 'algeria'
            PhraseList.new(:payment_method_in_algeria)
          else
            PhraseList.new(:standard_payment_method)
          end
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

        precalculate :registration_exception do
          phrases = PhraseList.new
          if same_country
            phrases << :"#{country_of_birth}_same_country_certificate_exception"
          else
            phrases << :"#{country_of_birth}_another_country_certificate_exception" << :contact_fco
          end
          phrases
        end
      end
    end
  end
end
