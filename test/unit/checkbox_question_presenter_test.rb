require_relative "../test_helper"

module SmartAnswer
  class CheckboxQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Checkbox.new(nil, :question_name?)
      @question.option(:option1)
      @question.option(:option2)
      @question.option(:option3)

      @renderer = stub("renderer")

      @renderer.stubs(:option).with(:option1).returns("Option 1")
      @renderer.stubs(:option).with(:option2).returns({ label: "Option 2", hint_text: "Hint 2" })
      @renderer.stubs(:option).with(:option3).returns({ label: "Option 3" })

      @presenter = CheckboxQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
    end

    test "#response_labels returns option labels for responses" do
      assert_equal ["Option 1", "Option 2"], @presenter.response_labels("option1,option2")
    end

    test "#response_labels returns default none label" do
      assert_equal %w[None], @presenter.response_labels("none")
    end

    test "#checkboxes return hashes of checkbox attributes" do
      assert_equal(%w[option1 option2 option3], @presenter.checkboxes.map { |c| c[:value] })
      assert_equal(["Option 1", "Option 2", "Option 3"], @presenter.checkboxes.map { |c| c[:label] })
      assert_equal([nil, "Hint 2", nil], @presenter.checkboxes.map { |c| c[:hint] })
      assert_equal([nil, nil, nil], @presenter.checkboxes.map { |c| c[:checked] })
    end

    test "#checkboxes return array including an or divider for none options" do
      @question.none_option
      @renderer.stubs(:option).with(:none).returns({ label: "None" })

      expected_value = [
        { label: "Option 1", value: "option1", hint: nil, checked: nil, exclusive: nil },
        { label: "Option 2", value: "option2", hint: "Hint 2", checked: nil, exclusive: nil },
        { label: "Option 3", value: "option3", hint: nil, checked: nil, exclusive: nil },
        :or,
        { label: "None", value: "none", hint: nil, checked: nil, exclusive: true },
      ]

      assert_equal expected_value, @presenter.checkboxes
    end

    test "#caption returns the given caption when a caption is given" do
      @renderer.stubs(:hide_caption).returns(false)
      @renderer.stubs(:content_for).with(:caption).returns("caption-text")

      assert_equal "caption-text", @presenter.caption
    end

    context "#checked?" do
      should "return true if value appears in string" do
        @presenter.stubs(:response_for_current_question).returns("option1,option2")
        assert @presenter.checked?("option2")
      end

      should "return true if value appears in array" do
        @presenter.stubs(:response_for_current_question).returns(%w[option1 option2])
        assert @presenter.checked?("option2")
      end
    end
  end
end
