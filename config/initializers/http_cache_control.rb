SmartAnswers::Application.configure do
  config.set_http_cache_control_expiry_time = if Rails.env.development?
                                                false
                                              else
                                                true
                                              end
end
