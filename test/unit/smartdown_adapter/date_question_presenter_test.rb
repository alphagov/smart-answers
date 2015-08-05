require_relative '../../test_helper'

module SmartdownAdapter
  class DateQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @presenter = SmartdownAdapter::DateQuestionPresenter.new(nil, nil)
    end

    context "to_response" do
      should "return hash form of date string" do
        assert_equal({ day: 2, month: 1, year: 2015 }, @presenter.to_response("2015-01-02"))
      end

      should "return nil if date string is invalid" do
        assert_equal nil, @presenter.to_response("invalid-date")
      end
    end
  end
end
