require "test_helper"

class CurrentQuestionHelperTest < ActionView::TestCase
  context "#current_question_path" do
    should "return link to smart answer" do
      assert_equal smart_answer_path(flow_name), current_question_path(presenter)
    end

    should "return link to session answer when flow uses sessions" do
      assert_equal update_flow_path(flow_name, node_name.dasherize), current_question_path(session_presenter)
    end
  end

  context "#restart_flow_path" do
    should "return root smart answer path" do
      assert_equal smart_answer_path(flow_name), restart_flow_path(presenter)
    end

    should "return root smart answer path for session answer" do
      assert_equal destroy_flow_path(flow_name), restart_flow_path(session_presenter)
    end
  end

  def flow_name
    "find-coronavirus-support"
  end

  def node_name
    "need_help_with"
  end

  def params
    @params ||= ActionController::Parameters.new(
      id: flow_name,
    )
  end

  def presenter
    @presenter ||= OpenStruct.new(
      accepted_responses: [],
      name: flow_name,
    )
  end

  def session_presenter
    @session_presenter ||= OpenStruct.new(
      response_store: :session,
      name: flow_name,
      node_slug: node_name.dasherize,
    )
  end
end
