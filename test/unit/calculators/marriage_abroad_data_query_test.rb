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
            keys = %w(countries_with_18_outcomes countries_with_2_outcomes)
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

          should "return empty array if data structure isn't an array of strings" do
            YAML.stubs(:load_file).returns(countries_with_18_outcomes: [{ sample: "value" }])

            assert_equal [], @data_query.countries_with_18_outcomes
          end

          should "return empty array if data structure is a Hash" do
            YAML.stubs(:load_file).returns(countries_with_18_outcomes: Hash.new)

            assert_equal [], @data_query.countries_with_18_outcomes
          end

          should "throw key not found exception if countries_with_18_outcomes is missing" do
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

          should "return empty array if data structure isn't an array of strings" do
            YAML.stubs(:load_file).returns(countries_with_18_outcomes: [{ sample: "value" }])

            assert_equal [], @data_query.countries_with_18_outcomes
          end

          should "return empty array if data structure is a Hash" do
            YAML.stubs(:load_file).returns(countries_with_18_outcomes: Hash.new)

            assert_equal [], @data_query.countries_with_18_outcomes
          end

          should "throw key not found exception if countries_with_2_outcomes is missing" do
            YAML.stubs(:load_file).returns({})

            exception = assert_raises KeyError do
              @data_query.countries_with_2_outcomes
            end

            assert_equal exception.message, "key not found: \"countries_with_2_outcomes\""
          end
        end
      end
    end
  end
end
