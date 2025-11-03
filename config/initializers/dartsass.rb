APP_STYLESHEETS = {
  "application.scss" => "application.css",
  "components/_result-card.scss" => "components/_result-card.css",
  "components/_result-item.scss" => "components/_result-item.css",
  "components/_result-sections.scss" => "components/_result-sections.css",
  "visualise.scss" => "visualise.css",
}.freeze

all_stylesheets = APP_STYLESHEETS.merge(GovukPublishingComponents::Config.component_guide_stylesheet)
Rails.application.config.dartsass.builds = all_stylesheets
Rails.application.config.dartsass.build_options << " --quiet-deps"
Rails.application.config.dartsass.build_options << " --silence-deprecation=import"
