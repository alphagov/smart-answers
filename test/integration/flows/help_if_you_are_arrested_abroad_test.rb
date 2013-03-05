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

    end

    context "Answering Greece" do
      setup do
        add_response :greece
      end

      should "take the user to answer 2" do
        assert_current_node :answer_two_has_pack
      end

      should "calculate a link for prison information" do
        assert_state_variable :prison, "- [Prison information](http://ukingreece.fco.gov.uk/resources/en/pdf/5610670/bns_in_prison)"
      end
    end

    context "Answering Belgium" do
      setup do
        add_response :belgium
      end

      should "take the user to answer 2" do
        assert_current_node :answer_two_has_pack
      end

      should "show both links for judicial information" do
        assert_state_variable :judicial, "- [Judicial system](http://ukinbelgium.fco.gov.uk/resources/en/pdf/consul-help-info)\n- [Judicial system](http://ukinbelgium.fco.gov.uk/resources/en/pdf/belgium-detention-info)"
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

end
