if Rails.env.production?
  SmartAnswers::Application.config.expose_govspeak = ENV['EXPOSE_GOVSPEAK'].present?
else
  SmartAnswers::Application.config.expose_govspeak = true
end
