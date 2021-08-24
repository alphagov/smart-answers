require "test_helper"

class PublishingApiRakeTest < ActiveSupport::TestCase
  context "publshing_api:sync_all" do
    setup { Rake::Task["publishing_api:sync_all"].reenable }

    should "sync all flows with ContentItemSyncer" do
      mock_syncer = mock("syncer")
      ContentItemSyncer.stubs(:new).returns(mock_syncer)

      mock_syncer.expects(:sync).with(SmartAnswer::FlowRegistry.instance.flows)

      Rake::Task["publishing_api:sync_all"].invoke
    end
  end

  context "publshing_api:sync" do
    setup { Rake::Task["publishing_api:sync"].reenable }

    should "sync a specified flow with ContentItemSyncer" do
      flow = mock("flow", name: "a-smart-answer")
      SmartAnswer::FlowRegistry.any_instance.stubs(flows: [flow])
      mock_syncer = mock("syncer")
      ContentItemSyncer.stubs(:new).returns(mock_syncer)
      mock_syncer.expects(:sync).with([flow])

      Rake::Task["publishing_api:sync"].invoke("a-smart-answer")
    end

    should "raise an error when given a slug that doesn't exist" do
      SmartAnswer::FlowRegistry.any_instance.stubs(flows: [])

      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:sync"].invoke("a-slug")
      end

      assert_equal "Smart Answer a-slug not found", exception.message
    end
  end

  context "publishing_api:unpublish_redirect" do
    setup do
      Rake::Task["publishing_api:unpublish_redirect"].reenable
    end

    should "raise exception when content_id isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:unpublish_redirect"].invoke
      end

      assert_equal "Missing content_id parameter", exception.message
    end

    should "raise exception when base_path isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:unpublish_redirect"]
          .invoke("content-id", nil, "/destination")
      end

      assert_equal "Missing base_path parameter", exception.message
    end

    should "raise exception when destination isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:unpublish_redirect"]
          .invoke("content-id", "/base-path", nil)
      end

      assert_equal "Missing destination parameter", exception.message
    end

    should "send an unpublishing of type redirect to the Publishing API" do
      WebMock.reset!
      unpublish_request = stub_publishing_api_unpublish(
        "content-id",
        body: { type: "redirect",
                discard_drafts: true,
                redirects: [{ path: "/base-path",
                              segments_mode: "ignore",
                              type: "prefix",
                              destination: "/new-destination" }] },
      )

      Rake::Task["publishing_api:unpublish_redirect"]
        .invoke("content-id", "/base-path", "/new-destination")
      assert_requested unpublish_request
    end

    should "allow specifying the redirect type as a parameter" do
      WebMock.reset!
      unpublish_request = stub_publishing_api_unpublish(
        "content-id",
        body: { type: "redirect",
                discard_drafts: true,
                redirects: [{ path: "/base-path",
                              segments_mode: "ignore",
                              type: "exact",
                              destination: "/new-destination" }] },
      )

      Rake::Task["publishing_api:unpublish_redirect"]
        .invoke("content-id", "/base-path", "/new-destination", "exact")
      assert_requested unpublish_request
    end
  end

  context "publishing_api:unpublish_gone rake task" do
    setup do
      Rake::Task["publishing_api:unpublish_gone"].reenable
    end

    should "raise exception when content_id isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:unpublish_gone"].invoke
      end

      assert_equal "Missing content_id parameter", exception.message
    end

    should "send an unpublishing of type gone to the Publishing API" do
      unpublish_request = stub_publishing_api_unpublish(
        "content-id",
        body: { type: "gone", discard_drafts: true },
      )

      Rake::Task["publishing_api:unpublish_gone"].invoke("content-id")
      assert_requested unpublish_request
    end
  end

  context "publishing_api:unpublish_gone_with_explanation rake task" do
    setup do
      Rake::Task["publishing_api:unpublish_gone_with_explanation"].reenable
    end

    should "raise exception when content_id isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:unpublish_gone_with_explanation"].invoke(nil, "explanation")
      end

      assert_equal "Missing content_id parameter", exception.message
    end

    should "raise exception when explanation isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:unpublish_gone_with_explanation"].invoke("content-id", nil)
      end

      assert_equal "Missing explanation parameter", exception.message
    end

    should "send an unpublishing of type gone to the Publishing API" do
      explanation = "The latest support and advice has been added to www.gov.uk/somewhere."
      unpublish_request = stub_publishing_api_unpublish(
        "content-id",
        body: { type: "gone", explanation: explanation, discard_drafts: true },
      )

      Rake::Task["publishing_api:unpublish_gone_with_explanation"].invoke("content-id", explanation)
      assert_requested unpublish_request
    end
  end

  context "publishing_api:unpublish_vanish rake task" do
    setup do
      Rake::Task["publishing_api:unpublish_vanish"].reenable
    end

    should "raise exception when content_id isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:unpublish_vanish"].invoke
      end

      assert_equal "Missing content_id parameter", exception.message
    end

    should "send an unpublishing of type vanish to the Publishing API" do
      unpublish_request = stub_publishing_api_unpublish(
        "content-id",
        body: { type: "vanish", discard_drafts: true },
      )

      Rake::Task["publishing_api:unpublish_vanish"].invoke("content-id")
      assert_requested unpublish_request
    end
  end

  context "publishing_api:change_owning_application rake task" do
    setup do
      Rake::Task["publishing_api:change_owning_application"].reenable
    end

    should "raise exception when base-path is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:change_owning_application"].invoke(nil, "a-publisher")
      end

      assert_equal "Missing base_path parameter", exception.message
    end

    should "raise exception when publishing_app not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:change_owning_application"].invoke("/base-path", nil)
      end

      assert_equal "Missing publishing_app parameter", exception.message
    end

    should "send a path reservation to the Publishing API" do
      reserve_request = stub_publishing_api_path_reservation(
        "/base-path",
        publishing_app: "a-publisher",
        override_existing: true,
      )

      Rake::Task["publishing_api:change_owning_application"].invoke("/base-path", "a-publisher")

      assert_requested reserve_request
    end
  end
end
