require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class UkVisaCalculatorMarch9ToApril62023Test < ActiveSupport::TestCase
      context "#july_19_to_august_16_2023_grace_period_country?" do
        %w[dominica honduras namibia timor-leste vanuatu].each do |country|
          should "return true passport_country is '#{country}'" do
            calculator = UkVisaCalculator.new
            calculator.passport_country = country
            assert calculator.july_19_to_august_16_2023_grace_period_country?
          end
        end

        should "return false if passport_country is not in the list" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "india"
          assert_not calculator.july_19_to_august_16_2023_grace_period_country?
        end
      end
    end
  end
end
