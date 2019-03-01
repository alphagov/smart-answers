# Flattening Marriage Abroad outcomes for a country

**1. Run the rake task to flatten the outcomes:**
  - `bundle exec rake marriage_abroad:flatten_outcomes[<your country>]`
  - `# e.g. bundle exec rake "marriage_abroad:flatten_outcomes[qatar]"`

**2. Add or move the country into the right section of these files:**
  - `lib/data/marriage_abroad_data.yml`
  - `test/integration/smart_answer_flows/marriage_abroad_test.rb`

**3. Update any special cases in these files:**
  - `test/integration/smart_answer_flows/marriage_abroad_test.rb`
  - `lib/smart_answer_flows/marriage-abroad.rb`

**4. Remove any special-case outcome files for the country here:**
  - `lib/smart_answer_flows/marriage-abroad/outcomes`
