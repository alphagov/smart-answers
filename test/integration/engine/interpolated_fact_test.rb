require_relative 'engine_test_helper'

require 'gds_api/test_helpers/fact_cave'

class InterpolatedFactTest < EngineIntegrationTest
  include GdsApi::TestHelpers::FactCave

  should "interpolate facts for smart answer intro body" do
    current_year = Time.now.year.to_s
    fact_cave_has_a_fact("current-year", current_year)

    visit "/interpolated-facts-sample"

    within ".intro" do
      assert_page_has_content "The current year is: #{current_year}"
    end
  end
end
