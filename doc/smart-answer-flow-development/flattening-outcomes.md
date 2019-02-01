# Flattening Marriage Abroad outcomes for a country

**1. Add or move the country into the right section of these files:**
  - `lib/data/marriage_abroad_data.yml`
  - `test/data/marriage-abroad-questions-and-responses.yml`
  - `test/integration/smart_answer_flows/marriage_abroad_test.rb`

**2. Update any special cases in these files:**
  - `test/integration/smart_answer_flows/marriage_abroad_test.rb`
  - `lib/smart_answer_flows/marriage-abroad.rb`

**3. Remove any special-case outcome files for the country here:**
  - `lib/smart_answer_flows/marriage-abroad/outcomes`

**4. Run the rake task to flatten the outcomes:**
  - `bundle exec rake marriage_abroad:flatten_outcomes[<your country>,<civil_partnership, same_sex_marriage, or both>]`
  - `# e.g. bundle exec rake "marriage_abroad:flatten_outcomes[qatar,both]"`

**5. Update the tests by running this script:**
  - `bin/prep_for_pull_request.sh marriage-abroad`
