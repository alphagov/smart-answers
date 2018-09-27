# Flattening Marriage Abroad outcomes for a country

1. Add or move the country into the right section of `lib/data/marriage_abroad_data.yml` and `test/data/marriage-abroad-questions-and-responses.yml`
2. `bundle exec rake marriage_abroad:flatten_outcomes[<your country>,<civil_partnership or same_sex_marriage>]` e.g. `marriage_abroad:flatten_outcomes[russia,same_sex_marriage]`
3. Move the country to the right array in `test/integration/smart_answer_flows/marriage_abroad_test.rb`
4. `bundle exec bin/prep_for_pull_request.sh marriage-abroad`
