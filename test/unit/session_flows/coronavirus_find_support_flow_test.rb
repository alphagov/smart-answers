require "test_helper"

class CoronavirusFindSupportFlowTest < ActiveSupport::TestCase
  def session
    @session ||= {}
  end

  def node
    @node ||= :need_help_with
  end

  def flow
    CoronavirusFindSupportFlow.new(node, session)
  end

  # Linear sections
  context "mental health worries" do
    setup do
      @node = :mental_health_worries
    end

    should "return nation" do
      assert_equal :nation, flow.next_node
    end
  end

  # Branching behaviour
  context "need help with feeling unsafe" do
    setup do
      @session = { need_help_with: [:feeling_unsafe] }
    end

    should "return start of feel safe segment" do
      assert_equal :feel_safe, flow.next_node
    end
  end

  context "need help with mental health" do
    setup do
      @session = { need_help_with: [:mental_health] }
    end

    should "return start of mental health segment" do
      assert_equal :mental_health_worries, flow.next_node
    end
  end

  context "need help with feeling unsafe and mental health" do
    setup do
      @session = { need_help_with: %i[feeling_unsafe mental_health] }
    end

    should "return start of feel safe segment" do
      assert_equal :feel_safe, flow.next_node
    end
  end

  context "need help with feeling unsafe and mental health after feel safe visited" do
    setup do
      @session = {
        need_help_with: %i[feeling_unsafe mental_health],
        feel_safe: :no,
      }
    end

    should "return start of mental health segment" do
      assert_equal :mental_health_worries, flow.next_node
    end
  end

  context "need help with feeling unsafe and mental health after feel safe, and mental health visited" do
    setup do
      @session = {
        need_help_with: %i[feeling_unsafe mental_health],
        feel_safe: :no,
        mental_health_worries: :no,
      }
    end

    should "return end of flow" do
      assert_equal :nation, flow.next_node
    end
  end

  # Special question behaviour
  context "when able to get food" do
    setup do
      @session = {
        need_help_with: [:getting_food],
        afford_food: "yes",
        get_food: "yes",
      }
      @node = :get_food
    end

    should "return next segment" do
      assert_equal :nation, flow.next_node
    end
  end

  context "when unable to get food" do
    setup do
      @session = {
        need_help_with: [:getting_food],
        afford_food: "yes",
        get_food: "no",
      }
      @node = :get_food
    end

    should "return start of mental health segment" do
      assert_equal :able_to_go_out, flow.next_node
    end
  end

  context "when self employed" do
    setup do
      @session = {
        need_help_with: [:getting_food],
        afford_food: "yes",
        self_employed: "yes",
      }
      @node = :self_employed
    end

    should "return worried about work" do
      assert_equal :worried_about_work, flow.next_node
    end
  end

  context "when not self employed" do
    setup do
      @session = {
        need_help_with: [:getting_food],
        afford_food: "yes",
        self_employed: "no",
      }
      @node = :self_employed
    end

    should "return have you been made unemployed" do
      assert_equal :have_you_been_made_unemployed, flow.next_node
    end
  end

  context "when made unemployed" do
    setup do
      @session = {
        need_help_with: [:getting_food],
        afford_food: "yes",
        have_you_been_made_unemployed: "yes_i_have_been_made_unemployed",
      }
      @node = :have_you_been_made_unemployed
    end

    should "return worried about work" do
      assert_equal :worried_about_work, flow.next_node
    end
  end

  context "when not made unemployed" do
    setup do
      @session = {
        need_help_with: [:getting_food],
        afford_food: "yes",
        have_you_been_made_unemployed: "no",
      }
      @node = :have_you_been_made_unemployed
    end

    should "return are you off ill" do
      assert_equal :are_you_off_work_ill, flow.next_node
    end
  end
end
