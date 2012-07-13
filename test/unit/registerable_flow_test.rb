require_relative '../test_helper'

class RegisterableFlowTest < ActiveSupport::TestCase

  context "slug" do
    should "use the flow name" do
      flow = stub("flow", name: "sample", slug: "slug")
      registerable = RegisterableFlow.new(flow)
      
      assert_equal "sample", registerable.slug
    end
  end

  context "title" do
    should "use the presenter's title" do
      SmartAnswerPresenter.any_instance.stubs(:title).returns("stubbed title")
      flow = stub("flow", name: "sample", slug: "sample")
      registerable = RegisterableFlow.new(flow)
      
      assert_equal "stubbed title", registerable.title
    end
  end

  context "need_id" do
    should "use the flow's need_id" do
      flow = stub("flow", name: "sample", slug: "sample", need_id: 123)
      registerable = RegisterableFlow.new(flow)
      
      assert_equal 123, registerable.need_id
    end
  end

  context "section" do
    should "use the presenter's section_name" do
      SmartAnswerPresenter.any_instance.stubs(:section_name).returns("stubbed section name")
      flow = stub("flow", name: "sample", slug: "sample")
      registerable = RegisterableFlow.new(flow)
      
      assert_equal "stubbed section name", registerable.section
    end
  end

  context "paths" do
    should "generate flow.name and flow.name.json" do
      flow = stub("flow", name: "sample", slug: "sample")
      registerable = RegisterableFlow.new(flow)
      
      assert_equal ["sample", "sample.json"], registerable.paths
    end
  end

  context "prefixes" do
    should "generate flow.name" do
      flow = stub("flow", name: "sample", slug: "sample")
      registerable = RegisterableFlow.new(flow)
      
      assert_equal ["sample"], registerable.prefixes
    end
  end

  context "description" do
    should "use TextPresenter's description" do
      TextPresenter.any_instance.stubs(:description).returns("stubbed description")
      flow = stub("flow", name: "sample", slug: "sample")
      registerable = RegisterableFlow.new(flow)
      
      assert_equal "stubbed description", registerable.description
    end
  end

  context "indexable_content" do
    should "use TextPresenter's text" do
      TextPresenter.any_instance.stubs(:text).returns("stubbed text")
      flow = stub("flow", name: "sample", slug: "sample")
      registerable = RegisterableFlow.new(flow)
      
      assert_equal "stubbed text", registerable.indexable_content
    end
  end

  context "live" do
    should "always return true, because the FlowRegistry decides what to register" do
      flow = stub("flow", name: "sample", status: :bananaman)
      registerable = RegisterableFlow.new(flow)

      assert_equal(true, registerable.live)
    end
  end
end
