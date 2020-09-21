require "test_helper"

class NodePresenterTest < ActiveSupport::TestCase
  def node
    OpenStruct.new(name: :foo_bar)
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
end
