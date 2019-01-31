# Flattening Marriage Abroad outcomes for a country

**1. Add or move the country into the right section of these files:**
  - `lib/data/marriage_abroad_data.yml`
  - `test/data/marriage-abroad-questions-and-responses.yml`

**2. Run the rake task to flatten the outcomes:**
  - `$ bundle exec rake marriage_abroad:flatten_outcomes[<your country>,<civil_partnership or same_sex_marriage>]`
  - `# e.g. bundle exec rake marriage_abroad:flatten_outcomes[russia,same_sex_marriage]`
  - **Note**: If you use `zsh`, the task name and arguments must be inside quotation marks, like so:
    - `$ bundle exec rake "marriage_abroad:flatten_outcomes[austria,same_sex_marriage]"`

**3. Move the country to the right array in this file:**
  - `test/integration/smart_answer_flows/marriage_abroad_test.rb`

**4. Update the tests by running this script:**
  - `$ bundle exec bin/prep_for_pull_request.sh marriage-abroad`
  - **Note**: You may need to also manually update test expectations in this file:
    - `test/integration/smart_answer_flows/marriage_abroad_test.rb`
