country_name = ARGV.shift
outcome_name = ARGV.shift

filename = 'marriage-abroad-responses-and-expected-results.yml'
filepath = Rails.root.join('test', 'data', filename)

yaml = File.read(filepath)
responses_and_expected_results = YAML.load(yaml)

data_for_outcome_and_country = responses_and_expected_results.select do |hash|
  hash[:next_node] == outcome_name.to_sym &&
    hash[:responses].first == country_name
end

response_sets = data_for_outcome_and_country.map do |hash|
  hash[:responses]
end

response_sets.each do |responses|
  puts responses.join(', ')
end
