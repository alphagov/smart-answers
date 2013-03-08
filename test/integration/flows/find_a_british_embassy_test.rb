# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class FindABritishEmbassyTest < ActiveSupport::TestCase
  include FlowTestHelper
  
  setup do
    setup_for_testing_flow 'find-a-british-embassy'
  end

  should "ask which country you want details for" do
    assert_current_node :choose_embassy_country?
  end

  context "details in afghanistan" do
    setup do
      add_response 'afghanistan'
    end
    should "go to outcome" do
      assert_current_node :embassy_outcome
      assert_state_variable :embassy_address, 'British Embassy'"\n"'15th Street, Roundabout Wazir Akbar Khan'"\n"'PO Box 334'"\n"'Kabul'"\n"'Afghanistan,Kabul'
      assert_state_variable :embassy_website, 'Website: http://ukinafghanistan.fco.gov.uk/en/'
      assert_state_variable :embassy_phone, 'Telephone: +93 (0) 700 102 000'
      assert_state_variable :embassy_email, 'Email: britishembassy.kabul@fco.gov.uk'
      assert_state_variable :embassy_office_hours, 'Office hours:'"\n"'0830-1630 (Sunday to Thursday)'
    end
  end
end
