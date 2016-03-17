module SmartAnswer::Calculators
  class PassportAndEmbassyDataQuery
    include ActionView::Helpers::NumberHelper

    ALT_EMBASSIES = {
      'benin' =>  'nigeria',
      'guinea' => 'ghana'
    }

    PASSPORT_COSTS = {
      'Australian Dollars'  => [[282.21], [325.81], [205.81]],
      'Euros'               => [[161, 186],   [195, 220],   [103, 128]],
      'New Zealand Dollars' => [["317.80", 337.69], ["371.80", 391.69], ["222.80", 242.69]],
      'SLL'                 => [[900000, 1135000], [1085000, 1320000], [575000, 810000]],
      'South African Rand'  => [[2112, 2440], [2549, 2877], [1345, 1673]]
    }

    CASH_ONLY_COUNTRIES = %w(cuba sudan)

    RENEWING_COUNTRIES = %w(belarus burma cuba lebanon libya russia sudan tajikistan tunisia turkmenistan uzbekistan zimbabwe)

    attr_reader :passport_data

    def initialize
      @passport_data = self.class.passport_data
    end

    def find_passport_data(country_slug)
      passport_data[country_slug]
    end

    def cash_only_countries?(country_slug)
      CASH_ONLY_COUNTRIES.include?(country_slug)
    end

    def renewing_countries?(country_slug)
      RENEWING_COUNTRIES.include?(country_slug)
    end

    def passport_costs
      {}.tap do |costs|
        PASSPORT_COSTS.each do |k, v|
          [:adult_32, :adult_48, :child].each_with_index do |t, i|
            key = "#{k.downcase.gsub(' ', '_')}_#{t}"
            costs[key] = v[i].map { |c| "#{number_with_delimiter(c)} #{k}"}.join(" | ")
          end
        end
      end
    end

    def self.passport_data
      @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data.yml"))
    end
  end
end
