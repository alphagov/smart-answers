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

      context '#passport_country_in_non_visa_national_list?' do
        should 'return true if passport_country is in list of non-visa national countries' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'andorra'
          assert calculator.passport_country_in_non_visa_national_list?
        end

        should 'return false if passport_country is not in list of non-visa national countries' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'made-up-country'
          refute calculator.passport_country_in_non_visa_national_list?
        end
      end

      context '#passport_country_in_ukot_list?' do
        should 'return true if passport_country is in list of uk overseas territories' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'anguilla'
          assert calculator.passport_country_in_ukot_list?
        end

        should 'return false if passport_country is not in list of uk overseas territories' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'made-up-country'
          refute calculator.passport_country_in_ukot_list?
        end
      end
    end
  end
end
