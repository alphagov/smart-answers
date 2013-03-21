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

    context "Answering with a country without any specific downloads / information" do

      context "Answering Andorra" do
        setup do
          add_response :andorra
        end

        should "take the user to the generic answer" do
          assert_current_node :answer_one_generic
        end

        should "correctly calculate and store the country variables" do
          assert_state_variable :country, "andorra"
          assert_state_variable :country_name, "Andorra"
        end

        should "correctly set up phrase lists" do
          assert_phrase_list :intro, [:common_intro]
          assert_phrase_list :generic_downloads, [:fco_link, :common_downloads]
          assert_phrase_list :after_downloads, [:fco_cant_do, :dual_nationals_other_help, :further_links]
          assert_state_variable :has_extra_downloads, false
          assert_phrase_list :country_downloads, []
        end

      end # context: Andorra

    end # context: country without specific info

    context "Answering with a country that has specific downloads / information" do

      context "Answering Belgium" do
        setup do
          add_response :belgium
        end

        should "take the user to the generic answer" do
          assert_current_node :answer_one_generic
        end

        should "set up the country specific downloads phraselist" do
          assert_state_variable :has_extra_downloads, true
          assert_phrase_list :country_downloads, [:specific_downloads]
        end

        should "correctly calculate other phrase lists" do
          assert_phrase_list :intro, [:common_intro]
          assert_phrase_list :generic_downloads, [:fco_link, :common_downloads]
          assert_phrase_list :after_downloads, [:fco_cant_do, :dual_nationals_other_help, :further_links]
        end
      end

      context "Answering Greece" do
        setup do
          add_response :greece
        end

        should "take the user to the generic answer" do
          assert_current_node :answer_one_generic
        end

        should "set up the country specific downloads phraselist" do
          assert_state_variable :has_extra_downloads, true
          assert_phrase_list :country_downloads, [:specific_downloads]
        end
      end

    end # context: country with specific info
  end # context: non special case

  context "In Iran" do
    setup do
      add_response :iran
    end

    should "take them to the special Iran outcome" do
      assert_current_node :answer_two_iran
      assert_phrase_list :downloads, [:common_downloads]
      assert_phrase_list :further_help_links, [:further_links]
    end

  end

  context "In Syria" do
    setup do
      add_response :syria
    end

    should "take the user to the Syria answer" do
      assert_current_node :answer_three_syria
      assert_phrase_list :downloads, [:common_downloads]
      assert_phrase_list :further_help_links, [:further_links]
    end
  end


end
