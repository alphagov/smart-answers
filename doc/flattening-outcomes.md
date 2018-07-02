# Flattening Marriage Abroad outcomes for a country

1. Put the country in the right section of `lib/data/marriage_abroad_data.yml` and `test/data/marriage-abroad-questions-and-responses.yml`
2. `bundle exec rake marriage_abroad:flatten_outcomes[<your country>,<civil_partnership or same_sex_marriage>]` e.g. `marriage_abroad:flatten_outcomes[russia,same_sex_marriage]`
3. Move the country to the right array in `test/integration/smart_answer_flows/marriage_abroad_test.rb`
4. `bundle exec rails runner script/generate-responses-and-expected-results-for-smart-answer.rb marriage-abroad`
5. Commit the changes to `test/data/marriage-abroad-responses-and-expected-results.yml`
6. `bundle exec rake checksums:update`
7. Commit the changes to `test/data/marriage-abroad-files.yml`
8. `RUN_REGRESSION_TESTS=marriage-abroad ruby test/regression/smart_answers_regression_test.rb`
9. Commit any changes to `test/artefacts`
