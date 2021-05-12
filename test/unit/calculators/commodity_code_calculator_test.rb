require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CommodityCodeCalculatorTest < ActiveSupport::TestCase
    context CommodityCodeCalculator do
      setup do
        @calculator = CommodityCodeCalculator.new
      end

      context "#commodity_code" do
        should "return a code for valid inputs" do
          @calculator.starch_glucose_weight = "0..5"
          @calculator.sucrose_weight = "0..5"
          @calculator.milk_fat_weight = "0..1.5"
          @calculator.milk_protein_weight = "0..2.5"

          assert_equal "000", @calculator.commodity_code
        end

        should "return nil for weights not matching a code" do
          @calculator.starch_glucose_weight = "75..100"
          @calculator.sucrose_weight = "5..100"
          @calculator.milk_fat_weight = "85..100"
          @calculator.milk_protein_weight = "0..100"

          assert_nil @calculator.commodity_code
        end

        should "return nil for invalid inputs" do
          @calculator.starch_glucose_weight = "invalid"
          @calculator.sucrose_weight = "5..100"
          @calculator.milk_fat_weight = "85..100"
          @calculator.milk_protein_weight = "0..100"

          assert_nil @calculator.commodity_code
        end
      end

      context "#has_commodity_code?" do
        should "return true if commodity code is valid" do
          @calculator.starch_glucose_weight = "0..5"
          @calculator.sucrose_weight = "0..5"
          @calculator.milk_fat_weight = "0..1.5"
          @calculator.milk_protein_weight = "0..2.5"

          assert_equal true, @calculator.has_commodity_code?
        end

        should "return false if commodity code doesn't exist" do
          @calculator.starch_glucose_weight = "75..100"
          @calculator.sucrose_weight = "5..100"
          @calculator.milk_fat_weight = "85..100"
          @calculator.milk_protein_weight = "0..100"

          assert_equal false, @calculator.has_commodity_code?
        end
      end

      context "#starch_or_glucose_options" do
        should "return the options hash for starch or glucose question" do
          options = {
            "0..5" => "0 - 4.99",
            "5..25" => "5 - 24.99",
            "25..50" => "25 - 49.99",
            "50..75" => "50 - 74.99",
            "75..100" => "75 or more",
          }

          assert_equal options, @calculator.starch_or_glucose_options
        end
      end

      context "#sucrose_options" do
        should "return the options hash when starch or glucose weight is 0..5" do
          @calculator.starch_glucose_weight = "0..5"

          options = {
            "0..5" => "0 - 4.99",
            "5..30" => "5 - 29.99",
            "30..50" => "30 - 49.99",
            "50..70" => "50 - 69.99",
            "70..100" => "70 or more",
          }

          assert_equal options, @calculator.sucrose_options
        end

        should "return the options hash when starch or glucose weight is 5..25" do
          @calculator.starch_glucose_weight = "5..25"

          options = {
            "0..5" => "0 - 4.99",
            "5..30" => "5 - 29.99",
            "30..50" => "30 - 49.99",
            "50..70" => "50 - 69.99",
            "70..100" => "70 or more",
          }

          assert_equal options, @calculator.sucrose_options
        end

        should "return the options hash when starch or glucose weight is 25..50" do
          @calculator.starch_glucose_weight = "25..50"

          options = {
            "0..5" => "0 - 4.99",
            "5..30" => "5 - 29.99",
            "30..50" => "30 - 49.99",
            "50..100" => "50 or more",
          }

          assert_equal options, @calculator.sucrose_options
        end

        should "return the options hash when starch or glucose weight is 50..75" do
          @calculator.starch_glucose_weight = "50..75"

          options = {
            "0..5" => "0 - 4.99",
            "5..30" => "5 - 29.99",
            "30..100" => "30 or more",
          }

          assert_equal options, @calculator.sucrose_options
        end

        should "return the options hash when starch or glucose weight is 75..100" do
          @calculator.starch_glucose_weight = "75..100"

          options = {
            "0..5" => "0 - 4.99",
            "5..100" => "5 or more",
          }

          assert_equal options, @calculator.sucrose_options
        end
      end

      context "#milk_fat_options" do
        should "return the options hash for milk fat question" do
          options = {
            "0..1.5" => "0 - 1.49",
            "1.5..3" => "1.5 - 2.99",
            "3..6" => "3 - 5.99",
            "6..9" => "6 - 8.99",
            "9..12" => "9 - 11.99",
            "12..18" => "12 - 17.99",
            "18..26" => "18 - 25.99",
            "26..40" => "26 - 39.99",
            "40..55" => "40 - 54.99",
            "55..70" => "55 - 69.99",
            "70..85" => "70 - 84.99",
            "85..100" => "85 or more",
          }

          assert_equal options, @calculator.milk_fat_options
        end
      end

      context "#milk_protein_options" do
        should "return the options hash when milk fat weight is 0..1.5" do
          @calculator.milk_fat_weight = "0..1.5"
          options = {
            "0..2.5" => "0 - 2.49",
            "2.5..6" => "2.5 - 5.99",
            "6..18" => "6 - 17.99",
            "18..30" => "18 - 29.99",
            "30..60" => "30 - 59.99",
            "60..100" => "60 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 1.5..3" do
          @calculator.milk_fat_weight = "1.5..3"
          options = {
            "0..2.5" => "0 - 2.49",
            "2.5..6" => "2.5 - 5.99",
            "6..18" => "6 - 17.99",
            "18..30" => "18 - 29.99",
            "30..60" => "30 - 59.99",
            "60..100" => "60 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 3..6" do
          @calculator.milk_fat_weight = "3..6"
          options = {
            "0..2.5" => "0 - 2.49",
            "2.5..12" => "2.5 - 11.99",
            "12..100" => "12 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 6..9" do
          @calculator.milk_fat_weight = "6..9"
          options = {
            "0..4" => "0 - 3.99",
            "4..15" => "4 - 14.99",
            "15..100" => "15 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 9..12" do
          @calculator.milk_fat_weight = "9..12"
          options = {
            "0..6" => "0 - 5.99",
            "6..18" => "6 - 17.99",
            "18..100" => "18 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 12..18" do
          @calculator.milk_fat_weight = "12..18"
          options = {
            "0..6" => "0 - 5.99",
            "6..18" => "6 - 17.99",
            "18..100" => "18 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 18..26" do
          @calculator.milk_fat_weight = "18..26"
          options = {
            "0..6" => "0 - 5.99",
            "6..100" => "6 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 26..40" do
          @calculator.milk_fat_weight = "26..40"
          options = {
            "0..6" => "0 - 5.99",
            "6..100" => "6 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 40..55" do
          @calculator.milk_fat_weight = "40..55"
          options = {
            "0..100" => "0 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 55..70" do
          @calculator.milk_fat_weight = "55..70"
          options = {
            "0..100" => "0 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 70..85" do
          @calculator.milk_fat_weight = "70..85"
          options = {
            "0..100" => "0 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end

        should "return the options hash when milk fat weight is 85..100" do
          @calculator.milk_fat_weight = "85..100"
          options = {
            "0..100" => "0 or more",
          }

          assert_equal options, @calculator.milk_protein_options
        end
      end
    end
  end
end
