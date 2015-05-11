SmartAnswers::Application.configure do
  if Rails.env.development? || Rails.env.test?
    config.set_http_cache_control_expiry_time = false
  else
    config.set_http_cache_control_expiry_time = true
  end
end
