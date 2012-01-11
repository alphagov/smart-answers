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

    # Calculate your holiday entitlement
    documents << {
      "title"             => "Calculate your holiday entitlement",
      "description"       => "Calculate your annual leave",
      "format"            => "calculator",
      "section"           => "work",
      "link"              => "/calculate-your-holiday-entitlement",
      "indexable_content" => "Use this calculator to work out how much statutory holiday leave you're entitled to."
    }

    Rummageable.index documents
  end
end
