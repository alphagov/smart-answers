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
    end
  end
end
