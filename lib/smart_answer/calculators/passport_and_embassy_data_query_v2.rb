module SmartAnswer::Calculators
  class PassportAndEmbassyDataQueryV2

    include ActionView::Helpers::NumberHelper

    FCO_APPLICATIONS_REGEXP = /^(dublin_ireland|hong_kong|india|madrid_spain|paris_france|pretoria_south_africa|washington_usa|wellington_new_zealand)$/
    IPS_APPLICATIONS_REGEXP = /^ips_application_\d$/
    NO_APPLICATION_REGEXP = /^(algeria|iran|syria)$/

    ALT_EMBASSIES = {
      'benin' =>  'nigeria',
      'djibouti' => 'kenya',
      'guinea' => 'ghana',
      'cote-d-ivoire' => 'ghana',
      'kyrgyzstan' => 'kazakhstan',
      'liberia' => 'ghana'
    }

    RETAIN_PASSPORT_COUNTRIES = %w(afghanistan angola bangladesh brazil burma burundi china cuba
                                   east-timor egypt eritrea georgia indonesia iraq laos lebanon
                                   libya morocco nepal north-korea pakistan rwanda
                                   sri-lanka sudan thailand timor-leste tunisia uganda yemen zambia)

    RETAIN_PASSPORT_COUNTRIES_HURRICANES = %w(anguilla antigua-and-barbuda bahamas bermuda bonaire-st-eustatius-saba british-virgin-islands cayman-islands curacao dominica dominican-republic french-guiana grenada guadeloupe guyana haiti martinique mexico montserrat st-maarten st-kitts-and-nevis st-lucia st-pierre-and-miquelon st-vincent-and-the-grenadines suriname trinidad-and-tobago turks-and-caicos-islands)

    PASSPORT_COSTS = {
      'Australian Dollars'  => [[282.21], [325.81], [205.81]],
      'Euros'               => [[154, 178],   [185, 209],   [98, 122]],
      'Indian Rupees'       => [[13450, 15900], [16250, 18700], [8600, 11050]],
      'Jordanian Dinars'    => [[144, 181], [174, 211], [92, 129]],
      'New Zealand Dollars' => [["317.80", 337.69], ["371.80", 391.69], ["222.80", 242.69]],
      'Pakistani Rupees'    => [[21120, 25260], [25490, 29630], [13450, 17590]],
      'Phillipine peso'     => [[8704, 10268], [10506, 12070], [5542, 7106]],
      'South African Rand'  => [[2048, 2366], [2472, 2790], [1304, 1622]]
    }

    BELFAST_APPLICATION_ADDRESS = %w(andorra cyprus greece portugal spain)

    DURHAM_APPLICATION_ADDRESS = %w(anguilla antigua-and-barbuda argentina aruba bahamas barbados belgium belize bermuda bolivia bonaire-st-eustatius-saba brazil british-virgin-islands canada cayman-islands chile colombia costa-rica curacao dominica dominican-republic ecuador egypt el-salvador france french-guiana grenada guadeloupe guatemala guyana haiti honduras iraq israel italy jamaica jerusalem-or-westbank jordan liechtenstein luxembourg malta martinique mexico monaco montserrat netherlands nicaragua panama paraguay peru san-marino st-kitts-and-nevis st-lucia st-maarten st-pierre-and-miquelon st-vincent-and-the-grenadines suriname switzerland trinidad-and-tobago turks-and-caicos-islands uruguay usa yemen)

    CASH_ONLY_COUNTRIES = %w(cuba gaza libya mauritania morocco sudan tunisia venezuela western-sahara)

    RENEWING_COUNTRIES = %w(azerbaijan belarus cuba georgia kazakhstan kyrgyzstan lebanon libya mauritania morocco russia sudan tajikistan tunisia turkmenistan ukraine uzbekistan western-sahara venezuela)

    attr_reader :passport_data

    def initialize
      @passport_data = self.class.passport_data
    end

    def find_passport_data(country_slug)
      passport_data[country_slug]
    end

    def retain_passport?(country_slug)
      RETAIN_PASSPORT_COUNTRIES.include?(country_slug)
    end

    def retain_passport_hurricanes?(country_slug)
      RETAIN_PASSPORT_COUNTRIES_HURRICANES.include?(country_slug)
    end

    def belfast_application_address?(country_slug)
      BELFAST_APPLICATION_ADDRESS.include?(country_slug)
    end

    def durham_application_address?(country_slug)
      DURHAM_APPLICATION_ADDRESS.include?(country_slug)
    end

    def cash_only_countries?(country_slug)
      CASH_ONLY_COUNTRIES.include?(country_slug)
    end

    def renewing_countries?(country_slug)
      RENEWING_COUNTRIES.include?(country_slug)
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
      @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data_v2.yml"))
    end
  end
end
