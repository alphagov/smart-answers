# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'


class WhatVisaToVisitUkTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w()
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'what-visa-to-visit-uk'
  end


end
