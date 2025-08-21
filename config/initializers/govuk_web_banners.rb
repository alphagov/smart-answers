Rails.application.config.emergency_banner_redis_client = Redis.new(
  url: ENV["EMERGENCY_BANNER_REDIS_URL"],
  reconnect_attempts: [0, 0.1, 0.25],
)
