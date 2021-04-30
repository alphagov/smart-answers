require_relative "../test_helper"

module SmartAnswer
  class NodeTest < ActiveSupport::TestCase
    setup do
      @flow = Flow.new
      @node = Outcome.new(@flow, "node-name")
      @load_path = FlowRegistry.instance.load_path
    end

    test "#template_directory returns flows load path if flow has no name" do
      assert_equal Pathname.new(@load_path), @node.template_directory
    end

    test "#template_directory returns the path to the templates belonging to the flow" do
      @flow.name("flow-name")

      expected_directory = Pathname.new(@load_path).join("flow-name")
      assert_equal expected_directory, @node.template_directory
    end

    test "#filesystem_friendly_name returns name without trailing question mark" do
      question = Question::Base.new(@flow, :how_much?)
      assert_equal "how_much", question.filesystem_friendly_name
    end

    test "#slug returns name without trailing question mark and underscores replaced with dashes" do
      question = Question::Base.new(@flow, :how_much?)
      assert_equal "how-much", question.slug
    end

    test "#view_template sets the view template name" do
      node = Node.new(@flow, "node-name") { view_template "view-name" }
      assert_equal "view-name", node.view_template_path
    end

    test "#view_template_path return nil is not set" do
      node = Node.new(@flow, "node-name")
      assert_nil node.view_template_path
    end
  end
end
