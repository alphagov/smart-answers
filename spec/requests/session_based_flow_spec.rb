RSpec.describe "Session based flow navigation", flow_dir: :fixture do
  let(:no_cache_header) { "max-age=0, private, must-revalidate, no-store" }

  context "urls have /s/ prefix" do
    it "redirects to first node" do
      get "/session-based/s"
      expect(response).to redirect_to("/session-based/s/question1")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "renders the first question" do
      get "/session-based/s/question1"
      expect(response).to render_template("smart_answers/question")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "redirects to preceding unanswered question" do
      get "/session-based/s/results"
      expect(response).to redirect_to("/session-based/s/question1")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "redirects to next node when valid response provided" do
      get "/session-based/s/question1/next", params: { response: "response1", next: "true" }
      expect(response).to redirect_to("/session-based/s/question2")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "redirects to same node when invalid response provided" do
      get "/session-based/s/question1/next", params: { response: "invalid", next: "true" }
      expect(response).to redirect_to("/session-based/s/question1")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "clears the session and redirects to the start page" do
      get "/session-based/s/destroy_session"
      expect(response).to redirect_to("/session-based")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "clears the session and redirects to another page" do
      get "/session-based/s/destroy_session", params: { ext_r: "true" }
      expect(response).to redirect_to("https://www.bbc.co.uk/weather")
    end
  end

  context "urls have /flow/ prefix" do
    it "redirects to first node" do
      get "/session-based/flow"
      expect(response).to redirect_to("/session-based/s/question1")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "renders the first question" do
      get "/session-based/flow/question1"
      expect(response).to render_template("smart_answers/question")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "redirects to preceding unanswered question" do
      get "/session-based/flow/results"
      expect(response).to redirect_to("/session-based/s/question1")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "redirects to next node when valid response provided" do
      get "/session-based/flow/question1/next", params: { response: "response1", next: "true" }
      expect(response).to redirect_to("/session-based/s/question2")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "redirects to same node when invalid response provided" do
      get "/session-based/flow/question1/next", params: { response: "invalid", next: "true" }
      expect(response).to redirect_to("/session-based/s/question1")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "clears the session and redirects to the start page" do
      get "/session-based/flow/destroy_session"
      expect(response).to redirect_to("/session-based")
      expect(response.headers["Cache-Control"]).to eq(no_cache_header)
    end

    it "clears the session and redirects to another page" do
      get "/session-based/flow/destroy_session", params: { ext_r: "true" }
      expect(response).to redirect_to("https://www.bbc.co.uk/weather")
    end
  end

  context "urls have /flow/ prefix, but are path based flows" do
    it "redirects requests to old route" do
      get "/path-based/flow"
      expect(response).to redirect_to("/path-based/y")
    end

    it "redirects requests for a specific node to old route" do
      get "/path-based/flow/question1"
      expect(response).to redirect_to("/path-based/y")
    end

    it "redirects requests for a next node to old route" do
      get "/path-based/flow/question1/next", params: { response: "response1", next: "true" }
      expect(response).to redirect_to("/path-based/y")
    end

    it "redirects requests for destroying session to old route" do
      get "/path-based/flow/destroy_session"
      expect(response).to redirect_to("/path-based/y")
    end
  end
end
