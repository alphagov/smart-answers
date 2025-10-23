module SmartAnswer
  class ContentBlock
    def initialize(embed_code)
      @embed_code = embed_code
    end

    delegate :render, to: :content_block

  private

    attr_reader :embed_code

    def content_block
      ContentBlockTools::ContentBlock.new(
        content_id: block_data["content_id"],
        title: block_data["title"],
        document_type: reference.document_type,
        details: block_data["details"],
        embed_code:,
      )
    end

    def reference
      @reference ||= ContentBlockTools::ContentBlockReference.from_string(embed_code)
    end

    def api_response
      @api_response ||= GdsApi.publishing_api.get_content_items(
        document_type: reference.document_type,
        content_id_aliases: [reference.identifier],
      )
    end

    def block_data
      @block_data ||= api_response["results"].first
    end
  end
end
