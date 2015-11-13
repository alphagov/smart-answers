require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class UkVisaCalculatorTest < ActiveSupport::TestCase
      context '#passport_country_in_eea?' do
        should 'return true if passport_country is in list of EEA countries' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'austria'
          assert calculator.passport_country_in_eea?
        end

        should 'return false if passport_country is not in list of EEA countries' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'made-up-country'
          refute calculator.passport_country_in_eea?
        end
      end
    end
  end
end
