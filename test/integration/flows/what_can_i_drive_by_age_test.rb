# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class WhatCanIDriveByAgeTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'what-can-i-drive-by-age'
  end

  should "ask how old you are" do
    assert_current_node :how_old_are_you?
  end

  should "be age_under_16 if under 16" do
    add_response 'under-16'
    assert_current_node :age_under_16
  end

  context "aged 16" do
    setup do
      add_response '16'
    end

    should "ask if getting DLA" do
      assert_current_node :are_you_getting_dla?
    end

    should "be age_16_with_dla if getting DLA" do
      add_response 'dla'
      assert_current_node :age_16_with_dla
    end

    should "be age_16 if not getting DLA" do
      add_response 'no-dla'
      assert_current_node :age_16
    end
  end # age 16

  context "aged 17" do
    setup do
      add_response '17'
    end

    should "ask if you're in the armed forces" do
      assert_current_node :are_you_in_the_armed_forces?
    end

    should "be age_17 if not in armed forces" do
      add_response 'not-armed-forces'
      assert_current_node :age_17
    end

    should "be age_17_20_armed_forces if in armed forces" do
      add_response 'armed-forces'
      assert_current_node :age_17_20_armed_forces
    end
  end # aged 17

  context "aged 18" do
    setup do
      add_response '18'
    end

    should "ask if you're in the armed forces" do
      assert_current_node :are_you_in_the_armed_forces?
    end

    should "be age_18 if not in armed forces" do
      add_response 'not-armed-forces'
      assert_current_node :age_18
    end

    should "be age_17_20_armed_forces if in armed forces" do
      add_response 'armed-forces'
      assert_current_node :age_17_20_armed_forces
    end
  end # aged 18

  context "aged 19-20" do
    setup do
      add_response '19-20'
    end

    should "ask if you're in the armed forces" do
      assert_current_node :are_you_in_the_armed_forces?
    end

    should "be age_19_20 if not in armed forces" do
      add_response 'not-armed-forces'
      assert_current_node :age_19_20
    end

    should "be age_17_20_armed_forces if in armed forces" do
      add_response 'armed-forces'
      assert_current_node :age_17_20_armed_forces
    end
  end # aged 19-20

  should "be age_21 if aged 21" do
    add_response '21'
    assert_current_node :age_21
  end

  should "be age_22_and_over ig aged 22 +" do
    add_response '22-plus'
    assert_current_node :age_22_and_over
  end # aged 21
end
