require_relative "../test_helper"

module SmartAnswer
  class YearQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Year.new(nil, :question_name?)
      @renderer = stub("renderer")

      @presenter = YearQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
    end

    test "#parsed_response returns current_response when it is a hash" do
      hash = { year: 2021 }
      @presenter.stubs(:current_response).returns(hash)

      assert_equal hash, @presenter.parsed_response
    end

    test "#parsed_response returns year details as a hash when current_response is a parsable string" do
      @presenter.stubs(:current_response).returns("2021")
      hash = { year: 2021 }
      assert_equal hash, @presenter.parsed_response
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
