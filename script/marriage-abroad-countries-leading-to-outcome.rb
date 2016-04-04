outcome_name = ARGV.shift

filename = 'marriage-abroad-responses-and-expected-results.yml'
filepath = Rails.root.join('test', 'data', filename)

yaml = File.read(filepath)
responses_and_expected_results = YAML.load(yaml)

data_for_outcome = responses_and_expected_results.select do |hash|
  hash[:next_node] == outcome_name.to_sym
end
responses_for_outcome = data_for_outcome.map do |hash|
  hash[:responses]
end
countries_for_outcome = responses_for_outcome.map(&:first).uniq

puts countries_for_outcome
