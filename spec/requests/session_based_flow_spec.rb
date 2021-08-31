RSpec.describe "Session based flow navigation", flow_dir: :fixture do
  let(:no_cache_header) { "max-age=0, private, must-revalidate, no-store" }

  it "redirects to first node" do
    get "/session-based/start"
    expect(response).to redirect_to("/session-based/question1")
    expect(response.headers["Cache-Control"]).to eq(no_cache_header)
  end

  it "renders the first question" do
    get "/session-based/question1"
    expect(response).to render_template("smart_answers/question")
    expect(response.headers["Cache-Control"]).to eq(no_cache_header)
  end

  it "redirects to preceding unanswered question" do
    get "/session-based/results"
    expect(response).to redirect_to("/session-based/question1")
    expect(response.headers["Cache-Control"]).to eq(no_cache_header)
  end

  it "redirects to next node when valid response provided" do
    get "/session-based/question1/next", params: { response: "response1", next: "true" }
    expect(response).to redirect_to("/session-based/question2")
    expect(response.headers["Cache-Control"]).to eq(no_cache_header)
  end

  it "redirects to same node when invalid response provided" do
    get "/session-based/question1/next", params: { response: "invalid", next: "true" }
    expect(response).to redirect_to("/session-based/question1")
    expect(response.headers["Cache-Control"]).to eq(no_cache_header)
  end

  it "clears the session and redirects to the start page" do
    get "/session-based/destroy_session"
    expect(response).to redirect_to("/session-based")
    expect(response.headers["Cache-Control"]).to eq(no_cache_header)
  end

  context "urls are for path based flows" do
    it "redirects requests to old route" do
      get "/path-based/start"
      expect(response).to redirect_to("/path-based/y")
    end

    it "redirects requests for a specific node to old route" do
      get "/path-based/question1"
      expect(response).to redirect_to("/path-based/y")
    end

    it "redirects requests for a next node to old route" do
      get "/path-based/question1/next", params: { response: "response1", next: "true" }
      expect(response).to redirect_to("/path-based/y")
    end

    it "redirects requests for destroying session to old route" do
      get "/path-based/destroy_session"
      expect(response).to redirect_to("/path-based/y")
    end
  end
end
