# This script allows you to "query" the marriage-abroad
# responses-and-expected-results data.
#
# Usage:
# $ rails r script/marriage-abroad-query-responses-and-expected-results.rb \
#   space separated list of responses
#
# Example:
# $ rails r script/marriage-abroad-query-responses-and-expected-results.rb \
#   malta uk partner_british
#
# Responses: malta/uk/partner_british/opposite_sex
#   Outcome: outcome_opposite_sex_marriage_in_commonwealth_countries
#
# Responses: malta/uk/partner_british/same_sex
#   Outcome: outcome_same_sex_marriage_and_civil_partnership_in_malta

responses = ARGV

filename = 'marriage-abroad-responses-and-expected-results.yml'
filepath = Rails.root.join('test', 'data', filename)

yaml = File.read(filepath)
responses_and_expected_results = YAML.load(yaml)

outcomes_for_responses = responses_and_expected_results.select do |hash|
  hash[:outcome_node] == true &&
    hash[:responses] & responses == responses
end

outcomes_for_responses.each do |hash|
  puts "Responses: #{hash[:responses].join('/')}"
  puts "  Outcome: #{hash[:next_node]}"
  puts
end
