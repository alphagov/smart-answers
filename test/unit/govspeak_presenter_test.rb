require_relative '../test_helper'

require 'ostruct'

module SmartAnswer
  class GovspeakPresenterTest < ActiveSupport::TestCase
    test "parses markdown into HTML" do
      assert_equal "<h1 id=\"this-is-a-title\">This is a title</h1>\n",
                   GovspeakPresenter.new("# This is a title").html
    end

    test "interpolates facts embedded in markdown and returns HTML" do
      stub_fact = stub("vat rate fact")
      stub_fact.stubs(:details).returns(OpenStruct.new(value: "20%"))
      GdsApi::FactCave.any_instance.stubs(:fact).returns(stub_fact)

      assert_equal "<p>VAT Rate: 20%</p>\n",
                   GovspeakPresenter.new("VAT Rate: [fact:vat-rate]").html
    end
  end
end
