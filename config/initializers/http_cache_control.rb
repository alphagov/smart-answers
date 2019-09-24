SmartAnswers::Application.configure do
  config.set_http_cache_control_expiry_time = if Rails.env.development? || Rails.env.test?
                                                false
                                              else
                                                true
                                              end
end
