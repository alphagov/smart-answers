# Flattening Marriage Abroad outcomes for a country

**1. Run the rake task to flatten the outcomes:**
  - `bundle exec rake marriage_abroad:flatten_outcomes[<your country>]`
  - `# e.g. bundle exec rake "marriage_abroad:flatten_outcomes[qatar]"`

**2. Add or move the country into the right section of these files:**
  - `config/smart_answers/marriage_abroad_data.yml`
  - `test/integration/flows/marriage_abroad_test.rb`

**3. Update any special cases in these files:**
  - `test/integration/flows/marriage_abroad_test.rb`
  - `app/flows/marriage_abroad_flow.rb`

**4. Remove any special-case outcome files for the country here:**
  - `app/flows/marriage_abroad/outcomes`
