require_relative "../test_helper"

module SmartAnswer
  class DateQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Date.new(nil, :question_name?)
      @renderer = stub("renderer")

      @presenter = DateQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
      @presenter.stubs(:response_for_current_question).returns("2021-01-05")
    end

    test "#selected_day returns the day" do
      assert @presenter.selected_day
    end

    test "#selected_month returns the month" do
      assert @presenter.selected_month
    end

    test "#selected_year returns the year" do
      assert @presenter.selected_year
    end
  end
end
