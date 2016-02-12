require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class MarriageAbroadCalculatorTest < ActiveSupport::TestCase
      context '#partner_british?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is british' do
          @calculator.partner_nationality = 'partner_british'
          assert @calculator.partner_british?
        end

        should 'be false if partner is not british' do
          @calculator.partner_nationality = 'not-partner_british'
          refute @calculator.partner_british?
        end
      end

      context '#partner_not_british?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is not british' do
          @calculator.partner_nationality = 'not-partner_british'
          assert @calculator.partner_not_british?
        end

        should 'be false if partner is british' do
          @calculator.partner_nationality = 'partner_british'
          refute @calculator.partner_not_british?
        end
      end

      context '#partner_is_national_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is a national of the ceremony country' do
          @calculator.partner_nationality = 'partner_local'
          assert @calculator.partner_is_national_of_ceremony_country?
        end

        should 'be false if partner is not a national of the ceremony country' do
          @calculator.partner_nationality = 'not-partner_local'
          refute @calculator.partner_is_national_of_ceremony_country?
        end
      end

      context '#partner_is_not_national_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is not a national of the ceremony country' do
          @calculator.partner_nationality = 'not-partner_local'
          assert @calculator.partner_is_not_national_of_ceremony_country?
        end

        should 'be false if partner is a national of the ceremony country' do
          @calculator.partner_nationality = 'partner_local'
          refute @calculator.partner_is_not_national_of_ceremony_country?
        end
      end

      context '#partner_is_neither_british_nor_a_national_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is a national of a country other than britain or the ceremony country' do
          @calculator.partner_nationality = 'partner_other'
          assert @calculator.partner_is_neither_british_nor_a_national_of_ceremony_country?
        end

        should 'be false if partner is not a national of a country other than britain or the ceremony country' do
          @calculator.partner_nationality = 'not-partner_other'
          refute @calculator.partner_is_neither_british_nor_a_national_of_ceremony_country?
        end
      end

      context '#resident_of_uk?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident of uk' do
          @calculator.resident_of = 'uk'
          assert @calculator.resident_of_uk?
        end

        should 'be false if not a resident of uk' do
          @calculator.resident_of = 'not-uk'
          refute @calculator.resident_of_uk?
        end
      end

      context '#resident_outside_of_uk?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if not resident of uk' do
          @calculator.resident_of = 'not-uk'
          assert @calculator.resident_outside_of_uk?
        end

        should 'be false if resident of uk' do
          @calculator.resident_of = 'uk'
          refute @calculator.resident_outside_of_uk?
        end
      end

      context '#resident_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident of ceremony country' do
          @calculator.resident_of = 'ceremony_country'
          assert @calculator.resident_of_ceremony_country?
        end

        should 'be false if not resident of ceremony country' do
          @calculator.resident_of = 'not-ceremony_country'
          refute @calculator.resident_of_ceremony_country?
        end
      end

      context '#resident_outside_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if not resident of ceremony country' do
          @calculator.resident_of = 'not-ceremony_country'
          assert @calculator.resident_outside_of_ceremony_country?
        end

        should 'be false if resident of ceremony country' do
          @calculator.resident_of = 'ceremony_country'
          refute @calculator.resident_outside_of_ceremony_country?
        end
      end

      context '#resident_of_third_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident of third country' do
          @calculator.resident_of = 'third_country'
          assert @calculator.resident_of_third_country?
        end

        should 'be false if not resident of third country' do
          @calculator.resident_of = 'not-third_country'
          refute @calculator.resident_of_third_country?
        end
      end

      context '#resident_outside_of_third_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident_of != "third_country"' do
          @calculator.resident_of = 'not-third_country'
          assert @calculator.resident_outside_of_third_country?
        end

        should 'be false if resident_of == "third_country"' do
          @calculator.resident_of = 'third_country'
          refute @calculator.resident_outside_of_third_country?
        end
      end

      context '#partner_is_opposite_sex?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true when partner is of the opposite sex' do
          @calculator.sex_of_your_partner = 'opposite_sex'
          assert @calculator.partner_is_opposite_sex?
        end

        should 'be false when partner is not of the opposite sex' do
          @calculator.sex_of_your_partner = 'not-opposite_sex'
          refute @calculator.partner_is_opposite_sex?
        end
      end

      context '#partner_is_same_sex?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true when partner is of the same sex' do
          @calculator.sex_of_your_partner = 'same_sex'
          assert @calculator.partner_is_same_sex?
        end

        should 'be false when partner is not of the same sex' do
          @calculator.sex_of_your_partner = 'not-same_sex'
          refute @calculator.partner_is_same_sex?
        end
      end
    end
  end
end
