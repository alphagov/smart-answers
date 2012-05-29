namespace :rummager do
  desc "Reindex search engine"
  task :index => :environment do
    documents = SmartAnswer::FlowRegistry.new(FLOW_REGISTRY_OPTIONS).flows.map { |flow|
      presenter = TextPresenter.new(flow)
      {
        "title"             => presenter.title,
        "description"       => presenter.description,
        "format"            => "smart_answer",
        "section"           => presenter.section_slug,
        "subsection"        => presenter.subsection_slug,
        "link"              => "/#{flow.name}",
        "indexable_content" => presenter.text,
      }
    }

    Rummageable.index documents.compact
  end
end
