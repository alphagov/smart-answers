require_relative "../test_helper"

module SmartAnswer
  class SalaryQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Salary.new(nil, :question_name?)
      @renderer = stub("renderer")

      @presenter = SalaryQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
    end

    test "#parsed_response returns current_response when it is a hash" do
      hash = { amount: 150, period: "week" }
      @presenter.stubs(:current_response).returns(hash)

      assert_equal hash, @presenter.parsed_response
    end

    test "#parsed_response returns salary details when current_response is a parsable string" do
      @presenter.stubs(:current_response).returns("100.0-month")

      assert_equal ({ amount: 100.0, period: "month" }), @presenter.parsed_response
    end

    test "#parsed_response returns an empty hash when current_response is an invalid input" do
      @presenter.stubs(:current_response).returns("blah-blah")

      assert_empty @presenter.parsed_response
    end

    test "#parsed_response returns an empty hash when current_response is blank" do
      @presenter.stubs(:current_response).returns("")

      assert_empty @presenter.parsed_response
    end
  end
end
