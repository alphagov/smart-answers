class MainstreamContentFetcher
  def self.with_curated_sidebar
    JSON.parse(
      File.read(
        Rails.root.join(
          "config",
          "mainstream_content_with_curated_sidebar.json"
        )
      )
    )
  end
end
