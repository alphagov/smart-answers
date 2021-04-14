RSpec.describe "Query parameter based flow navigation", flow_dir: :fixture do
  let(:cache_header) { "max-age=1800, public" }

  it "renders the landing page" do
    get "/query-parameters-based"
    expect(response).to render_template("smart_answers/landing")
    expect(response.headers["Cache-Control"]).to eq(cache_header)
  end

  it "redirects to first node" do
    get "/query-parameters-based/s"
    expect(response).to redirect_to("/query-parameters-based/s/question1")
    expect(response.headers["Cache-Control"]).to eq(cache_header)
  end

  it "renders the first question" do
    get "/query-parameters-based/s/question1"
    expect(response).to render_template("smart_answers/question")
    expect(response.headers["Cache-Control"]).to eq(cache_header)
  end

  it "redirects to preceding unanswered question" do
    get "/query-parameters-based/s/results"
    expect(response).to redirect_to("/query-parameters-based/s/question1")
    expect(response.headers["Cache-Control"]).to eq(cache_header)
  end

  it "redirects to next node when valid response provided" do
    get "/query-parameters-based/s/question1/next", params: { response: "response1", next: "true" }
    expect(response).to redirect_to("/query-parameters-based/s/question2?question1=response1")
    expect(response.headers["Cache-Control"]).to eq(cache_header)
  end

  it "redirects to same node when invalid response provided" do
    get "/query-parameters-based/s/question1/next", params: { response: "invalid", next: "true" }
    expect(response).to redirect_to("/query-parameters-based/s/question1?question1=invalid")
    expect(response.headers["Cache-Control"]).to eq(cache_header)
  end

  it "clears the session and redirects to the start page" do
    get "/query-parameters-based/s/destroy_session"
    expect(response).to redirect_to("/query-parameters-based")
    expect(response.headers["Cache-Control"]).to eq(cache_header)
  end

  it "clears the session and redirects to another page" do
    get "/query-parameters-based/s/destroy_session", params: { ext_r: "true" }
    expect(response).to redirect_to("https://www.bbc.co.uk/weather")
    expect(response.headers["Cache-Control"]).to eq(cache_header)
  end
end
