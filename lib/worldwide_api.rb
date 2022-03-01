class WorldwideApi
  def self.endpoint
    if !Rails.env.production? || ENV["HEROKU_APP_NAME"].present?
      GdsApi::Worldwide.new(Plek.new.website_root)
    else
      GdsApi::Worldwide.new(Plek.find("whitehall-frontend"))
    end
  end
end
