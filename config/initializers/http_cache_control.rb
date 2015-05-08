SmartAnswers::Application.configure do
  if Rails.env.development?
    config.set_http_cache_control_expiry_time = false
  else
    config.set_http_cache_control_expiry_time = true
  end
end
