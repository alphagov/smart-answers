# encoding: utf-8
require 'test_helper'
require 'smartdown_plugins/shared/data_partial'
require 'smartdown_plugins/register-a-birth-transition/render_time'
require 'smartdown_plugins/register-a-birth-transition/build_time'
require 'gds_api/test_helpers/worldwide'

module SmartdownPlugins

  class RegisterABirthTransitionTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Worldwide

    setup do
      @location_slugs = %w(american-samoa italy narnia netherlands usa)
      worldwide_api_has_locations(@location_slugs)
    end

    test "Type of office High Commission" do
      expected = "British high commission"
      country = OpenStruct.new(:value => "bangladesh")
      assert_equal expected, SmartdownPlugins::RegisterABirthTransition.embassy_high_commission_or_consulate(country)
    end

    test "Type of office British consulate" do
      expected = "British consulate"
      country = OpenStruct.new(:value => "china")
      assert_equal expected, SmartdownPlugins::RegisterABirthTransition.embassy_high_commission_or_consulate(country)
    end

    test "Type of office Trade & Cultural Office" do
      expected = "British Trade & Cultural Office"
      country = OpenStruct.new(:value => "taiwan")
      assert_equal expected, SmartdownPlugins::RegisterABirthTransition.embassy_high_commission_or_consulate(country)
    end

    test "Type of office British consulate general" do
      expected = "British consulate general"
      country = OpenStruct.new(:value => "brazil")
      assert_equal expected, SmartdownPlugins::RegisterABirthTransition.embassy_high_commission_or_consulate(country)
    end

    test "Type of office British embassy" do
      expected = "British embassy"
      country = OpenStruct.new(:value => "italy")
      assert_equal expected, SmartdownPlugins::RegisterABirthTransition.embassy_high_commission_or_consulate(country)
    end

    test "slug_with_lower_case_prefix gives the country name" do
      expected = "Italy"
      country = OpenStruct.new(:value => "italy")
      assert_equal expected, SmartdownPlugins::RegisterABirthTransition.slug_with_lower_case_prefix(country)
    end

    test "slug_with_lower_case_prefix gives the country name with a lower case article if appropriate" do
      expected = "the Netherlands"
      country = OpenStruct.new(:value => "netherlands")
      assert_equal expected, SmartdownPlugins::RegisterABirthTransition.slug_with_lower_case_prefix(country)
    end

    test "slug_with_lower_case_prefix gives you the name of the corresponding registration country" do
      expected = "Usa"
      country = OpenStruct.new(:value => "american-samoa")
      assert_equal expected, SmartdownPlugins::RegisterABirthTransition.slug_with_lower_case_prefix(country)
    end
  end
end
