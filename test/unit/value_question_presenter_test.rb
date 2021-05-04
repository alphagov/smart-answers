require_relative "../test_helper"

module SmartAnswer
  class ValueQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Base.new(nil, :question_name?)

      @renderer = stub("renderer")

      @presenter = ValueQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
    end

    test "#caption returns the given caption when a caption is given" do
      @renderer.stubs(:hide_caption).returns(false)
      @renderer.stubs(:content_for).with(:caption).returns("caption-text")

      assert_equal "caption-text", @presenter.caption
    end
  end
end
