require "open-uri"

unless location_slug = ARGV.shift
  puts "Usage: #{__FILE__} <location-slug>"
  exit 1
end

json = open("https://www.gov.uk/api/world-locations/#{location_slug}/organisations.json").read
organisations_fixture_path = Rails.root.join("test/fixtures/worldwide/#{location_slug}_organisations.json")
File.open(organisations_fixture_path, "w") do |file|
  file.puts json
end
