require_relative "../test_helper"

module SmartAnswer
  class RadioWithIntroQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::RadioWithIntro.new(nil, :question_name?)
      @renderer = stub("renderer")
      @presenter = RadioWithIntroQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
      @presenter.stubs(:current_response).returns(nil)
    end

    test "#radio_heading returns single line of content rendered for radio_heading block" do
      @renderer.stubs(:content_for).with(:radio_heading).returns("A good heading")

      assert_equal "A good heading", @presenter.radio_heading
    end
  end
end
