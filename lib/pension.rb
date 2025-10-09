class Pension < Data.define(:slug, :rates)
  Rate = Data.define(:slug, :title, :amount)

  class << self
    def find(slug)
      all.find { |pension| pension.slug == slug }
    end

    def all
      api_response["results"].map do |pension|
        rates = pension.fetch("details", {}).fetch("rates", []).map do |slug, details|
          Pension::Rate.new(slug:, title: details["title"], amount: details["amount"])
        end
        slug = pension["content_id_aliases"][0]["name"]
        new(slug:, rates:)
      end
    end

  private

    def api_response
      GdsApi.publishing_api.get_content_items(document_type: "content_block_pension", per_page: "500")
    end
  end
end
