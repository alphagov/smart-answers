require_relative "../test_helper"

module SmartAnswer
  class OutcomePresenterTest < ActiveSupport::TestCase
    setup do
      outcome = Outcome.new(nil, :outcome_name)
      @renderer = stub("renderer")
      @presenter = OutcomePresenter.new(outcome, nil, nil, renderer: @renderer)
    end

    test "renderer is constructed using template name and directory obtained from outcome node" do
      outcome_directory = Pathname.new("outcome-template-directory")
      outcome = stub("outcome", name: :outcome_name, template_directory: outcome_directory)

      SmartAnswer::ErbRenderer.expects(:new).with(
        has_entries(
          template_directory: responds_with(:to_s, "outcome-template-directory/outcomes"),
          template_name: "outcome_name",
        ),
      )

      OutcomePresenter.new(outcome, nil)
    end

    test "renderer is constructed with default helper modules" do
      outcome_directory = Pathname.new("outcome-template-directory")
      outcome = stub("outcome", name: :outcome_name, template_directory: outcome_directory)

      SmartAnswer::ErbRenderer.expects(:new).with(has_entry(helpers: [
        SmartAnswer::FormattingHelper,
        SmartAnswer::OverseasPassportsHelper,
        SmartAnswer::MarriageAbroadHelper,
      ]))

      OutcomePresenter.new(outcome, nil)
    end

    test "renderer is constructed with supplied helper modules" do
      outcome_directory = Pathname.new("outcome-template-directory")
      outcome = stub("outcome", name: :outcome_name, template_directory: outcome_directory)
      helper = Module.new

      SmartAnswer::ErbRenderer.expects(:new).with(has_entry(helpers: includes(helper)))

      OutcomePresenter.new(outcome, nil, nil, helpers: [helper])
    end

    test "#title returns single line of content rendered for title block" do
      @renderer.stubs(:content_for).with(:title).returns("title-text")

      assert_equal "title-text", @presenter.title
    end

    test "#body returns content rendered for body block" do
      @renderer.stubs(:content_for).with(:body).returns("body-html")

      assert_equal "body-html", @presenter.body
    end

    test "#next_steps returns content rendered for next_steps block" do
      @renderer.stubs(:content_for).with(:next_steps).returns("next-steps-html")

      assert_equal "next-steps-html", @presenter.next_steps
    end

    test "#banner returns content rendered for banner block" do
      @renderer.stubs(:content_for).with(:banner).returns("phase-banner-html")

      assert_equal "phase-banner-html", @presenter.banner
    end

    test "#view_template_path returns default when not set on node" do
      node = stub(view_template_path: nil)
      presenter = OutcomePresenter.new(node, nil, nil, renderer: @renderer)

      assert_equal "smart_answers/result", presenter.view_template_path
    end

    test "#view_template_path returns view template set on node" do
      node = stub(view_template_path: :alt_view)
      presenter = OutcomePresenter.new(node, nil, nil, renderer: @renderer)

      assert_equal :alt_view, presenter.view_template_path
    end
  end
end
