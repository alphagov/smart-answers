require_relative "../test_helper"

class ApiPresenterTest < ActiveSupport::TestCase
  def api_prsenter_for(current_node)
    flow_presenter = stub(current_node: current_node)
    ApiPresenter.new(flow_presenter).as_json
  end

  test "#as_json returns outcome response when journey has finished" do
    current_node = stub(is_a?: true, title: "Title", body: "Flow body")

    assert_equal(
      api_prsenter_for(current_node),
      _warning: "This is an unsupported API that will probably be removed!",
      state: "finished",
      title: "Title",
      body: "Flow body",
      outcome: "Title",
    )
  end

  test "#as_json returns question response when journey is ongoing" do
    current_node = stub(is_a?: false, title: "Title", body: "Flow body", hint: "hint", error: nil, options: {})

    assert_equal(
      api_prsenter_for(current_node),
      _warning: "This is an unsupported API that will probably be removed!",
      state: "asking",
      question_type: "mocha/mock",
      title: "Title",
      body: "Flow body",
      hint: "hint",
      error: nil,
      questions: [],
    )
  end
end
