require_relative "../test_helper"

module SmartAnswer
  class StartButtonTest < ActiveSupport::TestCase
    setup do
      StartButton.any_instance.stubs(:custom_text_and_link).returns(
        "customized-smart-answer": {
          text: "Custom text"
        }
      )
      @view = mock("view")
      @view.stubs(:smart_answer_path).returns("/another-smart-answer/y")
    end

    context "#text" do
      should "return Start now when smart answer hasn't been customized" do
        start_button = StartButton.new("another-smart-answer", @view)
        assert_equal "Start now", start_button.text
      end

      should "return Custom text when smart answer has been customized" do
        start_button = StartButton.new("customized-smart-answer", @view)
        assert_equal "Custom text", start_button.text
      end
    end

    context "#href" do
      should "return /another-smart-answer/y" do
        start_button = StartButton.new("another-smart-answer", @view)
        assert_equal "/another-smart-answer/y", start_button.href
      end
    end
  end
end
