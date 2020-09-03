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

    test "#heading_title when title_as_heading is false returns the flow title" do
      flow = stub("flow_presenter")
      outcome = OutcomePresenter.new(stub("outcome"), flow, nil, renderer: stub("renderer"))

      flow.stubs(:title).returns("flow-title")
      outcome.stubs(:title).returns("outcome-title")
      outcome.stubs(:title_as_heading?).returns(false)

      assert_equal outcome.heading_title, flow.title
    end

    test "#heading_title when title_as_heading is true returns the outcome title" do
      flow = stub("flow_presenter")
      outcome = OutcomePresenter.new(stub("outcome"), flow, nil, renderer: stub("renderer"))

      flow.stubs(:title).returns("flow-title")
      outcome.stubs(:title).returns("outcome-title")
      outcome.stubs(:title_as_heading?).returns(true)

      assert_equal outcome.heading_title, outcome.title
    end

    test "#body returns content rendered for body block" do
      @renderer.stubs(:content_for).with(:body).returns("body-html")

      assert_equal "body-html", @presenter.body
    end

    test "#next_steps returns content rendered for next_steps block" do
      @renderer.stubs(:content_for).with(:next_steps).returns("next-steps-html")

      assert_equal "next-steps-html", @presenter.next_steps
    end

    test "#relative_erb_template_path delegates to renderer" do
      @renderer.stubs(:relative_erb_template_path).returns("relative-erb-template-path")

      assert_equal "relative-erb-template-path", @presenter.relative_erb_template_path
    end
  end
end
