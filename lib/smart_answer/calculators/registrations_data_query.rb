module SmartAnswer::Calculators
  class RegistrationsDataQuery
    COMMONWEALTH_COUNTRIES = %w(anguilla australia bermuda british-indian-ocean-territory british-virgin-islands cayman-islands canada falkland-islands gibraltar ireland montserrat new-zealand pitcairn south-africa south-georgia-and-south-sandwich-islands st-helena-ascension-and-tristan-da-cunha turks-and-caicos-islands)

    COUNTRIES_WITH_CONSULATES = %w(china colombia israel russia turkey)

    COUNTRIES_WITH_CONSULATE_GENERALS = %w(brazil hong-kong turkey)

    COUNTRIES_WITH_BIRTH_REGISTRATION_EXCEPTION = %w(afghanistan iraq jordan kuwait oman pakistan qatar saudi-arabia united-arab-emirates)

    ORU_DOCUMENTS_VARIANT_COUNTRIES_BIRTH = %w(andorra belgium denmark finland france india israel italy japan monaco morocco nepal netherlands nigeria poland portugal russia sierra-leone south-korea spain sri-lanka sweden taiwan the-occupied-palestinian-territories turkey united-arab-emirates usa)

    ORU_DOCUMENTS_VARIANT_COUNTRIES_DEATH = %w(papua-new-guinea poland)

    ORU_COURIER_VARIANTS = %w(cambodia cameroon kenya nigeria north-korea papua-new-guinea uganda)

    ORU_COURIER_BY_HIGH_COMISSION = %w(cameroon kenya nigeria)

    HIGHER_RISK_COUNTRIES = %w(afghanistan algeria azerbaijan bangladesh bhutan colombia india iraq kenya lebanon libya nepal new-caledonia nigeria pakistan philippines russia sierra-leone somalia south-sudan sri-lanka sudan uganda)

    MAY_REQUIRE_DNA_TESTS = %w(libya somalia)

    ORU_REGISTRATION_DURATION = {
      "afghanistan" => "6 months",
      "algeria" => "12 weeks",
      "azerbaijan" => "10 weeks",
      "bangladesh" => "8 months",
      "bhutan" => "8 weeks",
      "colombia" => "8 weeks",
      "india" => "16 weeks",
      "iraq" => "12 weeks",
      "kenya" => "12 weeks",
      "lebanon" => "12 weeks",
      "libya" => "6 months",
      "nepal" => "10 weeks",
      "nigeria" => "14 weeks",
      "pakistan" => "6 months",
      "russia" => "10 weeks",
      "sierra-leone" => "12 weeks",
      "somalia" => "12 weeks",
      "south-sudan" => "12 weeks",
      "sri-lanka" => "12 weeks",
      "sudan" => "12 weeks",
      "philippines" => "16 weeks",
      "uganda" => "12 weeks",
    }

    attr_reader :data

    def initialize
      @data = self.class.registration_data
    end

    def has_birth_registration_exception?(country_slug)
      COUNTRIES_WITH_BIRTH_REGISTRATION_EXCEPTION.include?(country_slug)
    end

    def commonwealth_country?(country_slug)
      COMMONWEALTH_COUNTRIES.include?(country_slug)
    end

    def responded_with_commonwealth_country?
      SmartAnswer::Predicate::RespondedWith.new(COMMONWEALTH_COUNTRIES, "commonwealth country")
    end

    def has_consulate?(country_slug)
      COUNTRIES_WITH_CONSULATES.include?(country_slug)
    end

    def has_consulate_general?(country_slug)
      COUNTRIES_WITH_CONSULATE_GENERALS.include?(country_slug)
    end

    def may_require_dna_tests?(country_slug)
      MAY_REQUIRE_DNA_TESTS.include?(country_slug)
    end

    def registration_country_slug(country_slug)
      data['registration_country'][country_slug] || country_slug
    end

    def custom_registration_duration(country_slug)
      ORU_REGISTRATION_DURATION[country_slug]
    end

    def document_return_fees
      SmartAnswer::Calculators::RatesQuery.new('births_and_deaths_document_return_fees').rates
    end

    def self.registration_data
      @embassy_data ||= YAML.load_file(Rails.root.join("lib", "data", "registrations.yml"))
    end
  end
end
