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
        end
      end
    end
  end
end
