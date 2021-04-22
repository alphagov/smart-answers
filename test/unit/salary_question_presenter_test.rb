require_relative "../test_helper"

module SmartAnswer
  class SalaryQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Salary.new(nil, :question_name?)
      @renderer = stub("renderer")

      @presenter = SalaryQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
      @presenter.stubs(:response_for_current_question).returns("4000.0-month")
    end


    context "#amount" do
      should "return the amount" do
        assert_equal "4000.0", @presenter.amount.to_s
      end

      should "return the user input if the amount is invalid" do
        @presenter.stubs(:response_for_current_question).returns(amount: "-123", period: "week")
        assert_equal "-123", @presenter.amount
      end
    end
  end
end
