require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  context "#title_for_head" do
    context "with no title_prefix" do
      should "return the answer title + '- GOV.UK'" do
        assert_equal "Check Visa - GOV.UK", title_for_head(answer_title: "Check Visa")
      end
    end

    context "with a title_prefix" do
      should "return the title prefix + ' - ' + answer title + '- GOV.UK'" do
        assert_equal "How old are you? - Check Visa - GOV.UK", title_for_head(title_prefix: "How old are you?", answer_title: "Check Visa")
      end
    end
  end
end
