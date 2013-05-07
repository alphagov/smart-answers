module SmartAnswer::Calculators
  class PassportAndEmbassyDataQuery

    include ActionView::Helpers::NumberHelper

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
      'western-sahara' => 'morocco',
      'yemen' =>  'jordan'
    }

    RETAIN_PASSPORT_COUNTRIES = %w(afghanistan angola bangladesh brazil burma burundi china cuba
                                   east-timor egypt eritrea georgia indonesia iraq india laos lebanon
                                   libya morocco nepal north-korea pakistan rwanda
                                   sri-lanka sudan thailand timor-leste tunisia uganda yemen zambia)

    RETAIN_PASSPORT_COUNTRIES_HURRICANES = %w(anguilla antigua-and-barbuda bahamas bermuda bonaire-st-eustatius-saba british-virgin-islands cayman-islands curacao dominica,-commonwealth-of dominican-republic french-guiana grenada guadeloupe guyana haiti martinique mexico montserrat st-maarten st-kitts-and-nevis st-lucia st-pierre-and-miquelon st-vincent-and-the-grenadines suriname trinidad-and-tobago turks-and-caicos-islands)

    PASSPORT_COSTS = {
      'Jordanian Dinars'    => [[144, 181], [174, 211], [92, 129]],
      'South African Rand'  => [[1888, 2181], [2279, 2572], [1203, 1496]],
      'Euros'               => [[157, 182],   [190, 215],   [100, 125]]
    }

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

    def retain_passport_hurricanes?(country_slug)
      RETAIN_PASSPORT_COUNTRIES_HURRICANES.include?(country_slug)
    end

    def passport_costs
      {}.tap do |costs|
        PASSPORT_COSTS.each do |k,v|
          [:adult_32, :adult_48, :child].each_with_index do |t, i|
            key = "#{k.downcase.gsub(' ', '_')}_#{t}"
            costs[key] = v[i].map{ |c| "#{number_with_delimiter(c)} #{k}"}.join(" | ")
          end
        end
      end
    end

    def self.passport_data
      @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data.yml"))
    end

    def self.embassy_data
      @embassy_data ||= YAML.load_file(Rails.root.join("lib", "data", "embassies.yml"))
    end
  end
end
