module ForeignTravelAdviceHelper
  def stub_foreign_travel_advice
    response = {
      details: {
        parts: [
          {
            body: "<h2 id=\"all-travellers\">Header</h2><p>Content</p>" \
              "<h2 id=\"if-youre-transiting-through-spain\">Header</h2><p>Content</p>" \
              "<h2 id=\"if-youre-not-fully-vaccinated\">Header</h2><p>Content</p>" \
              "<h2 id=\"if-youre-fully-vaccinated\">Header</h2><p>Content</p>" \
              "<h2 id=\"children-and-young-people\">Header</h2><p>Content</p>" \
              "<h2 id=\"exemptions\">Header</h2><p>Content</p>",
            slug: "entry-requirements",
          },
        ],
      },
    }.to_json

    stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
      headers: { "Content-Type" => "application/json" },
    ).to_return(status: 200, body: response)

    stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/poland").with(
      headers: { "Content-Type" => "application/json" },
    ).to_return(status: 200, body: response)

    stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/ireland").with(
      headers: { "Content-Type" => "application/json" },
    ).to_return(status: 200, body: response)

    stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/ukraine").with(
      headers: { "Content-Type" => "application/json" },
    ).to_return(status: 200, body: response)
  end

  def stub_incomplete_foreign_travel_advice
    response = {
      details: {
        parts: [
          {
            body: "<h2 id=\"all-travellers\">Header</h2><p>Content</p>" \
              "<h2 id=\"if-youre-transiting-through-spain\">Header</h2><p>Content</p>" \
              "<h2 id=\"children-and-young-people\">Header</h2><p>Content</p>" \
              "<h2 id=\"exemptions\">Header</h2><p>Content</p>",
            slug: "entry-requirements",
          },
        ],
      },
    }.to_json

    stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
      headers: { "Content-Type" => "application/json" },
    ).to_return(status: 200, body: response)
  end

  def stub_unparsable_json_foreign_travel_advice
    stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
      headers: { "Content-Type" => "application/json" },
    ).to_return(status: 200, body: "")
  end

  def stub_server_timeout_foreign_travel_advice
    stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
      headers: { "Content-Type" => "application/json" },
    ).to_timeout
  end
end
