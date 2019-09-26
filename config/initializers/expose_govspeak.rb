SmartAnswers::Application.config.expose_govspeak = if Rails.env.production?
                                                     ENV["EXPOSE_GOVSPEAK"].present?
                                                   else
                                                     true
                                                   end
