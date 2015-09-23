
require_relative '../../test_helper'
#require_relative '../../helpers/test_fixtures_helper'

module SmartdownAdapter
  class TextQuestionPresenterTest < ActiveSupport::TestCase
    setup do
 #     use_test_smartdown_flow_fixtures
    end
    context "to_response" do
      should "strip leading and trailing whitespace" do
        presenter = SmartdownAdapter::TextQuestionPresenter.new("foo", nil)
        assert_equal "blah blah blah", presenter.to_response(" blah blah blah  ")
      end
    end
  end
end
 
