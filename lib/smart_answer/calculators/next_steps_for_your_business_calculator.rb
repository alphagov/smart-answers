require "companies_house/client"

# ======================================================================
# Allows access to the quesion answers provides custom validations
# and calculations, and other supporting methods.
# ======================================================================

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculator
    RESULT_DATA = YAML.load_file(Rails.root.join("config/smart_answers/next_steps_for_your_business.yml")).freeze

    def self.companies_house_client
      @companies_house_client ||= CompaniesHouse::Client.new(api_key: ENV["COMPANIES_HOUSE_API_KEY"])
    end

    attr_accessor :crn,
                  :annual_turnover,
                  :employ_someone,
                  :business_intent,
                  :business_support,
                  :business_premises

    def grouped_results
      RESULT_DATA.group_by { |result| result["section_name"] }
    end

    def company_exists?
      self.class.companies_house_client.company(crn).present?
    rescue CompaniesHouse::NotFoundError
      false
    end

    def company_name
      profile = self.class.companies_house_client.company(crn)
      profile["company_name"]
    rescue CompaniesHouse::APIError
      # Will try best attempt at getting company name, but not necessary for flow
    end
  end
end
