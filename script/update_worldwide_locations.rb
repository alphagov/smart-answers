world_locations_fixture_path = Rails.root.join("test/fixtures/worldwide_locations.yml")

File.open(world_locations_fixture_path, "w") do |file|
  locations = WorldLocation.all.map(&:slug)
  file.puts locations.to_yaml
end
