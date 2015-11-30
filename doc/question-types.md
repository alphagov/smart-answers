# Question types

* `checkbox_question`
  * User input: Choose zero to many options from a list of options.
  * Validation: Must be in the list of options.
  * Response: String containing comma-separated list of chosen options.

* `country_select`
  * Options:
    * `exclude_countries`: Optional. Array of countries to exclude from the list.
    * `include_uk`: Optional. Boolean indicating whether to include 'united-kingdom' in the list.
    * `additional_countries`: Optional. Array of countries to add to the list.
  * User input: Choose a single country.
  * Validation: Must be in the list of countries.
  * Response: String containing the chosen country.

* `date_question`
  * User input: Choose a single date.
  * Validation: Must be a valid date.
  * Response: `Date` object.

* `money_question`
  * User input: Enter a money amount.
  * Validation: Must be a number.
  * Response: `Money` object.

* `multiple_choice`
  * User input: Choose a single option from a list of options.
  * Validation: Must be in the list of options.
  * Response: String containing the chosen option.

* `postcode_question`
  * User input: Enter a postcode.
  * Validation: Must be a valid postcode.
  * Response: String containing a normalised postcode (e.g. "wc2b6nh" becomes "WC2B 6NH").

* `salary_question`
  * User input: Enter an Amount and associated Period.
  * Validation: Amount must be a valid `Money` object and Period must be one of 'year', 'month' or 'week'.
  * Response: `Salary` object.

* `value_question`
  * Options:
    * `parse`: Optional. One of `Integer`, `:to_i`, `Float` or `:to_f`
  * User input: Enter any text.
  * Validation (depends on the `parse` option):
    * `Integer`: Must be a number.
    * `:to_i`: Should be a number but non numbers are valid.
    * `Float`: Must be a number.
    * `:to_f`: Should be a number but non numbers are valid.
    * `<anything-else>`: No validation.
  * Response (depends on the `parse` option):
    * `Integer`: Integer.
    * `:to_i`: Integer (Non-numeric input returns 0).
    * `Float`: Float.
    * `:to_f`: Float (Non-numeric input returns 0.0).
    * `<anything-else>`: String containing the user input.
