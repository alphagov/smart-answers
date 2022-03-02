require "test_helper"

class NodePresenterTest < ActiveSupport::TestCase
  def node
    OpenStruct.new(name: :foo_bar, slug: "foo-bar", view_template_path: "view", redact: true)
  end

  def node_presenter
    @node_presenter ||= NodePresenter.new(node, nil)
  end

  context "#node_name" do
    should "return node name" do
      assert_equal :foo_bar, node_presenter.node_name
    end
  end

  context "#node_slug" do
    should "return version of node name for url path" do
      assert_equal "foo-bar", node_presenter.node_slug
    end
  end

  context "#view_template_path" do
    should "return view template name from the node" do
      assert_equal "view", node_presenter.view_template_path
    end
  end

  context "#redacted?" do
    should "return true id redact is set" do
      assert node_presenter.redacted?
    end
  end
end
