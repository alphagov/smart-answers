require 'gds_api/worldwide'

# In development, point at the public version of the API
# as we won't normally have whitehall running
if Rails.env.development?
  $worldwide_api = GdsApi::Worldwide.new("https://www.gov.uk")
else
  $worldwide_api = GdsApi::Worldwide.new(Plek.new.find('whitehall-admin'))
end
