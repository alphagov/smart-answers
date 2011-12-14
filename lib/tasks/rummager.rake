namespace :rummager do
  desc "Reindex search engine"
  task :index => :environment do
    documents = SmartAnswer::FlowRegistry.new.flows.map { |flow|
      presenter = TextPresenter.new(flow)
      {
        "title"             => presenter.title,
        "description"       => presenter.description,
        "format"            => "smart_answer",
        "section"           => presenter.section,
        "link"              => "/#{flow.name}",
        "indexable_content" => presenter.text,
      }
    }
    Rummageable.index documents
  end
end
