require_relative "../test_helper"

module SmartAnswer
  class DateQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Date.new(nil, :question_name?)
      @renderer = stub("renderer")

      @presenter = DateQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
      @presenter.stubs(:response_for_current_question).returns(
        {
          day: 5,
          month: 1,
          year: 2021,
        },
      )
    end

    test "#selected_day returns the day" do
      assert_equal 5, @presenter.selected_day
    end

    test "#selected_month returns the month" do
      assert_equal 1, @presenter.selected_month
    end

    test "#selected_year returns the year" do
      assert_equal 2021, @presenter.selected_year
    end
  end
end
