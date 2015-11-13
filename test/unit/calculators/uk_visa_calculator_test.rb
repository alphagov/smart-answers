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

      context '#passport_country_in_visa_national_list?' do
        should 'return true if passport_country is in list of visa national countries' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'armenia'
          assert calculator.passport_country_in_visa_national_list?
        end

        should 'return false if passport_country is not in list of visa national countries' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'made-up-country'
          refute calculator.passport_country_in_visa_national_list?
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

      context '#passport_country_in_datv_list?' do
        should 'return true if passport_country is in list of countries requiring a direct airside transit visa' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'afghanistan'
          assert calculator.passport_country_in_datv_list?
        end

        should 'return false if passport_country is not in list of countries requiring a direct airside transit visa' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'made-up-country'
          refute calculator.passport_country_in_datv_list?
        end
      end

      context '#tourism_visit?' do
        should 'return true if purpose_of_visit_answer is "tourism"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'tourism'
          assert calculator.tourism_visit?
        end

        should 'return false if purpose_of_visit_answer is not "tourism"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-tourism'
          refute calculator.tourism_visit?
        end
      end

      context '#work_visit?' do
        should 'return true if purpose_of_visit_answer is "work"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'work'
          assert calculator.work_visit?
        end

        should 'return false if purpose_of_visit_answer is not "work"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-work'
          refute calculator.work_visit?
        end
      end

      context '#study_visit?' do
        should 'return true if purpose_of_visit_answer is "study"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'study'
          assert calculator.study_visit?
        end

        should 'return false if purpose_of_visit_answer is not "study"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-study'
          refute calculator.study_visit?
        end
      end

      context '#transit_visit?' do
        should 'return true if purpose_of_visit_answer is "transit"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'transit'
          assert calculator.transit_visit?
        end

        should 'return false if purpose_of_visit_answer is not "transit"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-transit'
          refute calculator.transit_visit?
        end
      end

      context '#family_visit?' do
        should 'return true if purpose_of_visit_answer is "family"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'family'
          assert calculator.family_visit?
        end

        should 'return false if purpose_of_visit_answer is not "family"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-family'
          refute calculator.family_visit?
        end
      end

      context '#marriage_visit?' do
        should 'return true if purpose_of_visit_answer is "marriage"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'marriage'
          assert calculator.marriage_visit?
        end

        should 'return false if purpose_of_visit_answer is not "marriage"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-marriage'
          refute calculator.marriage_visit?
        end
      end

      context '#school_visit?' do
        should 'return true if purpose_of_visit_answer is "school"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'school'
          assert calculator.school_visit?
        end

        should 'return false if purpose_of_visit_answer is not "school"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-school'
          refute calculator.school_visit?
        end
      end

      context '#medical_visit?' do
        should 'return true if purpose_of_visit_answer is "medical"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'medical'
          assert calculator.medical_visit?
        end

        should 'return false if purpose_of_visit_answer is not "medical"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-medical'
          refute calculator.medical_visit?
        end
      end

      context '#diplomatic_visit?' do
        should 'return true if purpose_of_visit_answer is "diplomatic"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'diplomatic'
          assert calculator.diplomatic_visit?
        end

        should 'return false if purpose_of_visit_answer is not "diplomatic"' do
          calculator = UkVisaCalculator.new
          calculator.purpose_of_visit_answer = 'not-diplomatic'
          refute calculator.diplomatic_visit?
        end
      end

      context '#passport_country_in_youth_mobility_scheme_list?' do
        should 'return true if passport_country is in list of youth mobility scheme countries' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'australia'
          assert calculator.passport_country_in_youth_mobility_scheme_list?
        end

        should 'return false if passport_country is not in list of youth mobility scheme countries' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'made-up-country'
          refute calculator.passport_country_in_youth_mobility_scheme_list?
        end
      end

      context '#passport_country_in_electronic_visa_waiver_list?' do
        should 'return true if passport_country is in list of countries that can apply for an electronic visa waiver' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'oman'
          assert calculator.passport_country_in_electronic_visa_waiver_list?
        end

        should 'return false if passport_country is not in list of countries that can apply for an electronic visa waiver' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'made-up-country'
          refute calculator.passport_country_in_electronic_visa_waiver_list?
        end
      end

      context '#applicant_is_stateless_or_a_refugee?' do
        should 'return true if passport_country is "stateless-or-refugee"' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'stateless-or-refugee'
          assert calculator.applicant_is_stateless_or_a_refugee?
        end

        should 'return false if passport_country is not "stateless-or-refugee"' do
          calculator = UkVisaCalculator.new
          calculator.passport_country = 'not-stateless-or-refugee'
          refute calculator.applicant_is_stateless_or_a_refugee?
        end
      end
    end
  end
end
