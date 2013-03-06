module SmartAnswer::Calculators
  class PassportAndEmbassyDataQuery
 
    FCO_APPLICATIONS_REGEXP = /^(dublin_ireland|hong_kong|india|madrid_spain|paris_france|pretoria_south_africa|washington_usa|wellington_new_zealand)$/
    IPS_APPLICATIONS_REGEXP = /^ips_application_\d$/
    NO_APPLICATION_REGEXP = /^(algeria|iran|syria)$/

    ALT_EMBASSIES = {
      'benin' =>  'nigeria',
      'djibouti' => 'kenya',
      'guinea' => 'ghana',
      'iraq'  =>  'jordan',
      'ivory-coast' => 'ghana',
      'kyrgyzstan' => 'kazakhstan',
      'liberia' => 'ghana',
      'mauritania' => 'morocco',
      'togo' => 'ghana',
      'yemen' =>  'jordan'
    }

    RETAIN_PASSPORT_COUNTRIES = %w(afghanistan angola bangladesh burma burundi china cuba
                                   cyprus east-timor georgia indonesia iraq israel lebanon
                                   libya mauritius morocco north-korea pakistan rwanda
                                   sri-lanka sudan thailand tunisia uganda yemen zambia zimbabwe)

    attr_reader :embassy_data, :passport_data

    def initialize
      @embassy_data = self.class.embassy_data
      @passport_data = self.class.passport_data
    end

    def find_passport_data(country_slug)
      passport_data[country_slug]
    end

    def find_embassy_data(country_slug, alt=true)
      country_slug = ALT_EMBASSIES[country_slug] if alt and ALT_EMBASSIES.has_key?(country_slug)
      embassy_data[country_slug]
    end

    def retain_passport?(country_slug)
      RETAIN_PASSPORT_COUNTRIES.include?(country_slug)
    end

    def self.passport_data
      @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data.yml"))
    end

    def self.embassy_data
      @embassy_data ||= YAML.load_file(Rails.root.join("lib", "data", "embassies.yml"))
    end
  end
end
