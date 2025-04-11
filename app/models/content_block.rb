class ContentBlock
  def self.for_embed_code(embed_code)
    content_references = ContentBlockTools::ContentBlockReference.find_all_in_document(embed_code)
    result = GdsApi.publishing_api.get_content(content_references[0].content_id).parsed_content
    content_block = ContentBlockTools::ContentBlock.new(
      document_type: result["document_type"],
      content_id: result["content_id"],
      title: result["title"],
      details: result["details"],
      embed_code: embed_code,
    )
    content_block.render
  end
end
