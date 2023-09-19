require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class UkVisaCalculatorTest < ActiveSupport::TestCase
      context "#passport_country_in_eea?" do
        should "return true if passport_country is in list of EEA countries" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "austria"
          assert calculator.passport_country_in_eea?
        end

        should "return false if passport_country is not in list of EEA countries" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "made-up-country"
          assert_not calculator.passport_country_in_eea?
        end
      end

      context "#passport_country_in_visa_national_list?" do
        should "return true if passport_country is in list of visa national countries" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "armenia"
          assert calculator.passport_country_in_visa_national_list?
        end

        should "return false if passport_country is not in list of visa national countries" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "made-up-country"
          assert_not calculator.passport_country_in_visa_national_list?
        end
      end

      context "#passport_country_in_non_visa_national_list?" do
        should "return true if passport_country is in list of non-visa national countries" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "andorra"
          assert calculator.passport_country_in_non_visa_national_list?
        end

        should "return false if passport_country is not in list of non-visa national countries" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "made-up-country"
          assert_not calculator.passport_country_in_non_visa_national_list?
        end
      end

      context "#passport_country_in_british_overseas_territories_list?" do
        should "return true if passport_country is in list of uk overseas territories" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "anguilla"
          assert calculator.passport_country_in_british_overseas_territories_list?
        end

        should "return false if passport_country is not in list of uk overseas territories" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "made-up-country"
          assert_not calculator.passport_country_in_british_overseas_territories_list?
        end
      end

      context "#passport_country_in_direct_airside_transit_visa_list?" do
        should "return true if passport_country is in list of countries requiring a direct airside transit visa" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "afghanistan"
          assert calculator.requires_a_direct_airside_transit_visa?
        end

        should "return false if passport_country is not in list of countries requiring a direct airside transit visa" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "made-up-country"
          assert_not calculator.requires_a_direct_airside_transit_visa?
        end
      end

      context "#passport_country_in_electronic_visa_waiver_list?" do
        should "return true if passport_country is in list of countries that can apply for an electronic visa waiver" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "oman"
          assert calculator.has_passport_requiring_electronic_visa_waiver_list?
        end

        should "return false if passport_country is not in list of countries that can apply for an electronic visa waiver" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "made-up-country"
          assert_not calculator.has_passport_requiring_electronic_visa_waiver_list?
        end
      end

      context "#passport_country_in_electronic_travel_authorisation_list?" do
        should "return true if passport_country is in list of countries that can apply for an electronic travel authorisation" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "qatar"
          assert calculator.passport_country_requires_electronic_travel_authorisation?
        end

        should "return false if passport_country is not in list of countries that can apply for an electronic travel authorisation" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "made-up-country"
          assert_not calculator.passport_country_requires_electronic_travel_authorisation?
        end
      end

      context "#passport_country_in_epassport_gate_list?" do
        should "return true if passport_country is in list of countries that can use ePassport Gates" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "usa"
          assert calculator.passport_country_in_epassport_gate_list?
        end

        should "return false if passport_country is not in list of countries that can use ePassport Gates" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "made-up-country"
          assert_not calculator.passport_country_in_epassport_gate_list?
        end
      end

      context "#passport_country_in_british_national_overseas_list?" do
        should "return true if passport_country is in list of countries that are British nationals overseas" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "british-national-overseas"
          assert calculator.passport_country_in_british_national_overseas_list?
        end

        should "return false if passport_country is not in list of countries that are British nationals overseas" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "usa"
          assert_not calculator.passport_country_in_british_national_overseas_list?
        end
      end

      context "#passport_country_is_estonia?" do
        should "return true if passport_country is Estonia" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "estonia"
          assert calculator.passport_country_is_estonia?
        end

        should "return false if passport_country is not Estonia" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "not-estonia"
          assert_not calculator.passport_country_is_estonia?
        end

        should "return true if user has an alien passport" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "estonia-alien-passport"
          assert calculator.passport_country_is_estonia?
        end
      end

      context "#passport_country_is_latvia?" do
        should "return true if passport_country is Latvia" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "latvia"
          assert calculator.passport_country_is_latvia?
        end

        should "return false if passport_country is not Latvia" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "not-latvia"
          assert_not calculator.passport_country_is_latvia?
        end

        should "return true of user has an alien passport" do
          calculator = UkVisaCalculator.new
          calculator.passport_country = "latvia-alien-passport"
          assert calculator.passport_country_is_latvia?
        end
      end

      context "#travelling_to_cta?" do
        context "eligible_for_india_young_professionals_scheme?" do
          %w[health digital academic arts religious business other].each do |work_type|
            should "return true if passport country is India, visiting for work, staying for over six months and type of work is #{work_type}" do
              calculator = UkVisaCalculator.new
              calculator.passport_country = "india"
              calculator.purpose_of_visit_answer = "work"
              calculator.length_of_stay = "longer_than_six_months"
              calculator.what_type_of_work = work_type
              assert calculator.eligible_for_india_young_professionals_scheme?
            end
          end

          should "return false if passport country is India, visiting for work, staying for over six months and type of work is sports" do
            calculator = UkVisaCalculator.new
            calculator.passport_country = "india"
            calculator.purpose_of_visit_answer = "work"
            calculator.length_of_stay = "longer_than_six_months"
            calculator.what_type_of_work = "sports"
            assert_not calculator.eligible_for_india_young_professionals_scheme?
          end

          should "return false if visiting for work, staying for over six months and type of work is not sports and passport country is not India" do
            calculator = UkVisaCalculator.new
            calculator.passport_country = "france"
            calculator.purpose_of_visit_answer = "work"
            calculator.length_of_stay = "longer_than_six_months"
            calculator.what_type_of_work = "health"
            assert_not calculator.eligible_for_india_young_professionals_scheme?
          end

          should "return false if passport country is India, not visiting for work, staying for over six months and type of work is not sports" do
            calculator = UkVisaCalculator.new
            calculator.passport_country = "india"
            calculator.purpose_of_visit_answer = "tourism"
            calculator.length_of_stay = "longer_than_six_months"
            calculator.what_type_of_work = "health"
            assert_not calculator.eligible_for_india_young_professionals_scheme?
          end

          should "return false if passport country is India, visiting for work, staying for under six months and type of work is not sports" do
            calculator = UkVisaCalculator.new
            calculator.passport_country = "india"
            calculator.purpose_of_visit_answer = "work"
            calculator.length_of_stay = "less_than_six_months"
            calculator.what_type_of_work = "health"
            assert_not calculator.eligible_for_india_young_professionals_scheme?
          end
        end

        context "eligible_for_secondment_visa?" do
          should "return true if visiting for work, for longer than six months and doing 'other' work " do
            calculator = UkVisaCalculator.new
            calculator.purpose_of_visit_answer = "work"
            calculator.length_of_stay = "longer_than_six_months"
            calculator.what_type_of_work = "other"
            assert calculator.eligible_for_secondment_visa?
          end

          should "return false if not visiting for work" do
            calculator = UkVisaCalculator.new
            calculator.purpose_of_visit_answer = "study"
            calculator.length_of_stay = "longer_than_six_months"
            calculator.what_type_of_work = "other"
            assert_not calculator.eligible_for_secondment_visa?
          end

          should "return false if visiting for less than six months" do
            calculator = UkVisaCalculator.new
            calculator.purpose_of_visit_answer = "work"
            calculator.length_of_stay = "six_months_or_less"
            calculator.what_type_of_work = "other"
            assert_not calculator.eligible_for_secondment_visa?
          end

          should "return false if not doing 'other' work " do
            calculator = UkVisaCalculator.new
            calculator.purpose_of_visit_answer = "work"
            calculator.length_of_stay = "longer_than_six_months"
            calculator.what_type_of_work = "health"
            assert_not calculator.eligible_for_secondment_visa?
          end
        end
      end
    end
  end
end
