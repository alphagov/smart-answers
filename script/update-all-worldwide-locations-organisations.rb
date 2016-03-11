require "open-uri"

world_locations_fixture_path = Rails.root.join("test/fixtures/worldwide_locations.yml")

world_locations_yaml = File.read(world_locations_fixture_path)
world_locations = YAML.load(world_locations_yaml)

world_locations.each do |location_slug|
  json = open("https://www.gov.uk/api/world-locations/#{location_slug}/organisations.json").read
  organisations_fixture_path = Rails.root.join("test/fixtures/worldwide/#{location_slug}_organisations.json")
  File.open(organisations_fixture_path, "w") do |file|
    file.puts json
  end
end
