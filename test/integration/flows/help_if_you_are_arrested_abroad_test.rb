require_relative "../../test_helper"
require_relative "flow_test_helper"

class HelpIfYouAreArrestedAbroad < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "help-if-you-are-arrested-abroad"
  end

  should "ask which country the arrest is in" do
    assert_current_node :which_country?
  end

  context "In a country with a prisoner pack" do

    context "Answering Andorra" do
      setup do
        add_response :andorra
      end

      should "take the user to Answer 2" do
        assert_current_node :answer_two_has_pack
      end

      should "correctly calculate and store the country variables" do
        assert_state_variable :country, "andorra"
        assert_state_variable :country_name, "Andorra"
      end

      should "set pack_url to be the url of the prisoner pack" do
        assert_state_variable :pack_url, "http://www.fco.gov.uk/en/travel-and-living-abroad/when-things-go-wrong/arrest"
      end
    end

  end
  context "In Iran" do
    setup do
      add_response :iran
    end

    should "take them to the special Iran outcome" do
      assert_current_node :answer_three_iran
    end
  end

  context "In Syria" do
    setup do
      add_response :syria
    end

    should "take the user to the Syria answer" do
      assert_current_node :answer_four_syria
    end
  end

  # context "In a country with no prisoner pack" do
  #   setup do
  #     add_response :british_consulate_general_cape_town
  #   end

  #   should "take the user to answer one" do
  #     assert_current_node :answer_one_no_pack
  #   end
  # end
end
