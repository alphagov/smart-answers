require "test_helper"

class NodePresenterTest < ActiveSupport::TestCase
  def node
    OpenStruct.new(name: :foo_bar, slug: "foo-bar", view_template_path: "view")
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
    should "return true if node is redacted" do
      node = OpenStruct.new(name: :foo_bar, slug: "foo-bar", view_template_path: "view", redact: true)
      node_presenter = NodePresenter.new(node, nil)

      assert_equal true, node_presenter.redacted?
    end

    should "return false if node is not redacted" do
      node = OpenStruct.new(name: :foo_bar, slug: "foo-bar", view_template_path: "view", redact: false)
      node_presenter = NodePresenter.new(node, nil)

      assert_equal false, node_presenter.redacted?
    end
  end
end
