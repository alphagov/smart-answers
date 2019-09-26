require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class MarriageAbroadDataQueryTest < ActiveSupport::TestCase
      context MarriageAbroadDataQuery do
        setup do
          @data_query = MarriageAbroadDataQuery.new
        end

        context "#marriage_data" do
          should "load data from yaml file only once" do
            YAML.stubs(:load_file).returns({})
            YAML.expects(:load_file).once.returns({})

            @data_query.marriage_data
            @data_query.marriage_data
          end

          should "load data from correct path leading to marriage_abroad_data.yml" do
            path = Rails.root.join("lib", "data", "marriage_abroad_data.yml")
            YAML.stubs(:load_file).returns({})

            YAML.expects(:load_file).with(path).returns({})

            @data_query.marriage_data
          end

          should "only contain pre-defined data keys" do
            keys = %w(countries_with_18_outcomes countries_with_2_outcomes countries_with_2_outcomes_marriage_or_pacs countries_with_6_outcomes countries_with_ceremony_location_outcomes countries_with_1_outcome)
            data = @data_query.marriage_data

            assert_equal keys, data.keys
          end
        end

        context "#countries_with_18_outcomes" do
          should "returns countries that are listed to have 18 outcomes" do
            YAML.stubs(:load_file).returns(countries_with_18_outcomes: %w(anguilla bermuda))

            assert_equal %w(anguilla bermuda), @data_query.countries_with_18_outcomes
          end

          should "return empty array if no country is found" do
            YAML.stubs(:load_file).returns(countries_with_18_outcomes: nil)

            assert_equal [], @data_query.countries_with_18_outcomes
          end

          should "throw RuntimeError if data structure isn't an array of strings" do
            YAML.stubs(:load_file).returns(countries_with_18_outcomes: [{ sample: "value" }])

            exception = assert_raises RuntimeError do
              @data_query.countries_with_18_outcomes
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw RuntimeError if data structure is a Hash" do
            YAML.stubs(:load_file).returns(countries_with_18_outcomes: Hash.new)

            exception = assert_raises RuntimeError do
              @data_query.countries_with_18_outcomes
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw KeyError if countries_with_18_outcomes is missing" do
            YAML.stubs(:load_file).returns({})

            exception = assert_raises KeyError do
              @data_query.countries_with_18_outcomes
            end

            assert_equal exception.message, "key not found: \"countries_with_18_outcomes\""
          end
        end

        context "#countries_with_2_outcomes" do
          should "returns countries that are listed to have 2 outcomes" do
            YAML.stubs(:load_file).returns(countries_with_2_outcomes: %w(aruba bonaire-st-eustatius-saba))

            assert_equal %w(aruba bonaire-st-eustatius-saba), @data_query.countries_with_2_outcomes
          end

          should "return empty array if no country is found" do
            YAML.stubs(:load_file).returns(countries_with_2_outcomes: nil)

            assert_equal [], @data_query.countries_with_2_outcomes
          end

          should "throw RuntimeError if data structure isn't an array of strings" do
            YAML.stubs(:load_file).returns(countries_with_2_outcomes: [{ sample: "value" }])

            exception = assert_raises RuntimeError do
              @data_query.countries_with_2_outcomes
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw RuntimeError if data structure is a Hash" do
            YAML.stubs(:load_file).returns(countries_with_2_outcomes: Hash.new)

            exception = assert_raises RuntimeError do
              @data_query.countries_with_2_outcomes
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw KeyError if countries_with_2_outcomes is missing" do
            YAML.stubs(:load_file).returns({})

            exception = assert_raises KeyError do
              @data_query.countries_with_2_outcomes
            end

            assert_equal exception.message, "key not found: \"countries_with_2_outcomes\""
          end
        end

        context "#countries_with_2_outcomes_marriage_or_pacs" do
          should "returns countries that are listed to have 2 marriage or pacs outcomes" do
            YAML.stubs(:load_file).returns(countries_with_2_outcomes_marriage_or_pacs: %w(monaco wallis-and-futuna new-caledonia))

            assert_equal %w(monaco wallis-and-futuna new-caledonia), @data_query.countries_with_2_outcomes_marriage_or_pacs
          end

          should "return empty array if no country is found" do
            YAML.stubs(:load_file).returns(countries_with_2_outcomes_marriage_or_pacs: nil)

            assert_equal [], @data_query.countries_with_2_outcomes_marriage_or_pacs
          end

          should "throw RuntimeError if data structure isn't an array of strings" do
            YAML.stubs(:load_file).returns(countries_with_2_outcomes_marriage_or_pacs: [{ sample: "value" }])

            exception = assert_raises RuntimeError do
              @data_query.countries_with_2_outcomes_marriage_or_pacs
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw RuntimeError if data structure is a Hash" do
            YAML.stubs(:load_file).returns(countries_with_2_outcomes_marriage_or_pacs: Hash.new)

            exception = assert_raises RuntimeError do
              @data_query.countries_with_2_outcomes_marriage_or_pacs
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw KeyError if countries_with_2_outcomes_marriage_or_pacs is missing" do
            YAML.stubs(:load_file).returns({})

            exception = assert_raises KeyError do
              @data_query.countries_with_2_outcomes_marriage_or_pacs
            end

            assert_equal exception.message, "key not found: \"countries_with_2_outcomes_marriage_or_pacs\""
          end
        end

        context "#countries_with_6_outcomes" do
          should "returns countries that are listed to have 6 outcomes" do
            YAML.stubs(:load_file).returns(countries_with_6_outcomes: %w(argentina brazil))

            assert_equal %w(argentina brazil), @data_query.countries_with_6_outcomes
          end

          should "return empty array if no country is found" do
            YAML.stubs(:load_file).returns(countries_with_6_outcomes: nil)

            assert_equal [], @data_query.countries_with_6_outcomes
          end

          should "throw RuntimeError if data structure isn't an array of strings" do
            YAML.stubs(:load_file).returns(countries_with_6_outcomes: [{ sample: "value" }])

            exception = assert_raises RuntimeError do
              @data_query.countries_with_6_outcomes
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw RuntimeError if data structure is a Hash" do
            YAML.stubs(:load_file).returns(countries_with_6_outcomes: Hash.new)

            exception = assert_raises RuntimeError do
              @data_query.countries_with_6_outcomes
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw KeyError if countries_with_6_outcomes is missing" do
            YAML.stubs(:load_file).returns({})

            exception = assert_raises KeyError do
              @data_query.countries_with_6_outcomes
            end

            assert_equal exception.message, "key not found: \"countries_with_6_outcomes\""
          end
        end

        context "#countries_with_ceremony_location_outcomes" do
          should "returns countries that are listed to have ceremony location outcomes" do
            YAML.stubs(:load_file).returns(countries_with_ceremony_location_outcomes: %w(finland))

            assert_equal %w(finland), @data_query.countries_with_ceremony_location_outcomes
          end

          should "return empty array if no country is found" do
            YAML.stubs(:load_file).returns(countries_with_ceremony_location_outcomes: nil)

            assert_equal [], @data_query.countries_with_ceremony_location_outcomes
          end

          should "throw RuntimeError if data structure isn't an array of strings" do
            YAML.stubs(:load_file).returns(countries_with_ceremony_location_outcomes: [{ sample: "value" }])

            exception = assert_raises RuntimeError do
              @data_query.countries_with_ceremony_location_outcomes
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw RuntimeError if data structure is a Hash" do
            YAML.stubs(:load_file).returns(countries_with_ceremony_location_outcomes: Hash.new)

            exception = assert_raises RuntimeError do
              @data_query.countries_with_ceremony_location_outcomes
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw KeyError if countries_with_ceremony_location_outcomes is missing" do
            YAML.stubs(:load_file).returns({})

            exception = assert_raises KeyError do
              @data_query.countries_with_ceremony_location_outcomes
            end

            assert_equal exception.message, "key not found: \"countries_with_ceremony_location_outcomes\""
          end
        end

        context "#countries_with_1_outcome" do
          should "returns countries that are listed to have 1 outcomes" do
            YAML.stubs(:load_file).returns(countries_with_1_outcome: %w(monaco new-caledonia))

            assert_equal %w(monaco new-caledonia), @data_query.countries_with_1_outcome
          end

          should "return empty array if no country is found" do
            YAML.stubs(:load_file).returns(countries_with_1_outcome: nil)

            assert_equal [], @data_query.countries_with_1_outcome
          end

          should "throw RuntimeError if data structure isn't an array of strings" do
            YAML.stubs(:load_file).returns(countries_with_1_outcome: [{ sample: "value" }])

            exception = assert_raises RuntimeError do
              @data_query.countries_with_1_outcome
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw RuntimeError if data structure is a Hash" do
            YAML.stubs(:load_file).returns(countries_with_1_outcome: Hash.new)

            exception = assert_raises RuntimeError do
              @data_query.countries_with_1_outcome
            end

            assert_equal exception.message, "Country list must be an array of strings"
          end

          should "throw KeyError if countries_with_1_outcome is missing" do
            YAML.stubs(:load_file).returns({})

            exception = assert_raises KeyError do
              @data_query.countries_with_1_outcome
            end

            assert_equal exception.message, "key not found: \"countries_with_1_outcome\""
          end
        end

        context "#outcome_per_path_countries" do
          should "return an alphabetical list of countries under all outcome groups" do
            YAML.stubs(:load_file).returns(
              countries_with_18_outcomes: %w(anguilla),
              countries_with_6_outcomes: %w(bermuda),
              countries_with_2_outcomes: %w(cayman-islands),
              countries_with_2_outcomes_marriage_or_pacs: %w(monaco),
              countries_with_ceremony_location_outcomes: %w(finland),
              countries_with_1_outcome: %w(french-guiana),
            )

            assert_equal @data_query.outcome_per_path_countries,
                         %w(anguilla bermuda cayman-islands finland french-guiana monaco)
          end
        end
      end
    end
  end
end
