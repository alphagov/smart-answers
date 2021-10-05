require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class FlowControllerTest < ActionController::TestCase
  include SmartAnswersControllerTestHelper

  setup do
    setup_fixture_flows
    Rails.application.config.stubs(:set_http_cache_control_expiry_time).returns(true)
  end

  teardown { teardown_fixture_flows }

  context "GET /<id>" do
    should "display landing page in html if no questions answered yet" do
      get :landing, params: { id: "radio-sample" }
      assert_select "h1", /Sample radio question/
    end

    should "not have noindex tag on landing page" do
      get :landing, params: { id: "radio-sample" }
      assert_select "meta[name=robots][content=noindex]", count: 0
    end

    should "have cache headers set to 30 mins" do
      get :landing, params: { id: "radio-sample" }
      assert_cached_response
    end

    context "meta description in erb template" do
      should "be shown" do
        get :landing, params: { id: "radio-sample" }
        assert_select "head meta[name=description]" do |meta_tags|
          assert_equal "This is a test description", meta_tags.first["content"]
        end
      end
    end
  end

  context "GET /<id>/start" do
    should "redirect to the first question with cache headers for a query parameter flow" do
      get :start, params: { id: "query-parameters-based" }
      assert_redirected_to "/query-parameters-based/question1"
      assert_cached_response
    end

    should "redirect to the first question without cache headers for a session flow" do
      get :start, params: { id: "session-based" }
      assert_redirected_to "/session-based/question1"
      assert_uncached_response
    end

    should "redirect to the first question with cache headers for a path based flow" do
      get :start, params: { id: "radio-sample" }
      assert_redirected_to "/radio-sample/y"
      assert_cached_response
    end
  end

  context "GET /<id>/<node_slug>" do
    should "render a question if the requested question can be reached" do
      get :show, params: { id: "query-parameters-based", node_slug: "question1" }
      assert_select "h1", "Question 1 title"
    end

    should "redirect to the latest reachable question if the requested question cannot be reached" do
      get :show,
          params: { id: "query-parameters-based",
                    node_slug: "unexpected-question",
                    question1: "response1" }

      assert_redirected_to "/query-parameters-based/question2?question1=response1"
    end

    should "return a cached response for a query parameter flow" do
      get :show, params: { id: "query-parameters-based", node_slug: "question1" }
      assert_cached_response
    end

    should "return an uncached response for a session flow" do
      get :show, params: { id: "session-based", node_slug: "question1" }
      assert_uncached_response
    end

    should "redirect to the first question with cache headers for a path based flow" do
      get :show, params: { id: "radio-sample", node_slug: "anything" }
      assert_redirected_to "/radio-sample/y"
      assert_cached_response
    end
  end

  context "GET /<id>/<node_slug>/next" do
    context "for a session flow" do
      should "store the answer in the session" do
        get :update,
            params: { id: "session-based",
                      node_slug: "question1",
                      response: "answer" }

        assert_equal({ "question1" => "answer" }, session["session-based"])
      end

      should "redirect to the next question for a valid answer" do
        get :update,
            params: { id: "session-based",
                      node_slug: "question1",
                      response: "response1" }

        assert_redirected_to "/session-based/question2"
      end

      should "redirect to the current question for an invalid answer" do
        get :update,
            params: { id: "session-based",
                      node_slug: "question1",
                      response: "invalid" }

        assert_redirected_to "/session-based/question1"
      end

      should "return an uncached response" do
        get :update,
            params: { id: "session-based",
                      node_slug: "question1",
                      response: "response1" }

        assert_uncached_response
      end
    end

    context "for a query parameter flow" do
      should "redirect to the next question for a valid answer" do
        get :update,
            params: { id: "query-parameters-based",
                      node_slug: "question1",
                      response: "response1" }

        assert_redirected_to "/query-parameters-based/question2?question1=response1"
      end

      should "redirect to the current question for an invalid answer" do
        get :update,
            params: { id: "query-parameters-based",
                      node_slug: "question1",
                      response: "invalid" }

        assert_redirected_to "/query-parameters-based/question1?question1=invalid"
      end

      should "return a cached response" do
        get :update,
            params: { id: "query-parameters-based",
                      node_slug: "question1",
                      response: "response1" }

        assert_cached_response
      end
    end

    should "redirect to the first question with cache headers for a path based flow" do
      get :update, params: { id: "radio-sample", node_slug: "anything" }
      assert_redirected_to "/radio-sample/y"
      assert_cached_response
    end
  end

  context "GET /<id>/destroy_session" do
    context "for a session flow" do
      should "redirect to the start page without cache headers" do
        get :destroy, params: { id: "session-based" }
        assert_redirected_to "/session-based"
        assert_uncached_response
      end

      should "remove responses from the session" do
        session["session-based"] = { "question1" => "response1" }
        get :destroy, params: { id: "session-based" }
        assert_nil session["session-based"]
      end
    end

    context "for a query parameter flow" do
      should "redirect to the start page with cache headers" do
        get :destroy, params: { id: "query-parameters-based" }
        assert_redirected_to "/query-parameters-based"
        assert_cached_response
      end

      should "remove any answers from the query string" do
        get :destroy, params: { id: "query-parameters-based", question1: "response1" }
        assert_redirected_to "/query-parameters-based"
      end
    end

    should "redirect to the first question with cache headers for a path based flow" do
      get :destroy, params: { id: "radio-sample" }
      assert_redirected_to "/radio-sample/y"
      assert_cached_response
    end
  end

  def assert_cached_response
    assert_equal "max-age=1800, public", @response.header["Cache-Control"]
  end

  def assert_uncached_response
    assert_equal "no-store", @response.header["Cache-Control"]
  end
end
