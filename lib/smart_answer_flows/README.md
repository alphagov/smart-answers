# Ruby/YAML Smart Answers

README for Ruby and YAML-based smart answer flows

Smart answer flows are stored in `lib/smart_answer_flows/*.rb`. Corresponding text is in
`lib/smart_answer_flows/locales/*.yml`.
The code responsible for executing the flow of those questions is in the `lib` folder of this project.

## Smart answer syntax

### Question types

* `multiple_choice` - choose a single value from a list of values. Response is a string.
* `checkbox_question` - choose multiple values from a list of values. Response is a list.
* `country_select` - choose a single country.
* `date_question` - choose a single date
* `value_question` - enter a single string value (free text)
* `money_question` - enter a money amount. The response is converted to a `Money` object.
* `salary_question` - enter a salary as either a weekly or monthly money amount. Coverted to a `Salary` object.

### Defining next node rules

There are two syntaxes for defining next node rules. The older syntax uses a block which returns a symbol indicating the next node. This syntax is deprecated.

```ruby
next_node do |response|
  response == 'green' ? :green : :red
end
```

The disadvantage of this syntax is that it's not possible to analyze the flow to find out the possible paths through the flow. A newer syntax has been created which allows the flow to be analyzed and a [visualisation](http://www.gov.uk/check-uk-visa/visualise) to be produced.

Here is the same logic expressed using the new syntax:

```ruby
next_node_if(:green, responded_with('green')) )
next_node(:red)
```

The `responded_with` function actually returns a [predicate](http://en.wikipedia.org/wiki/Predicate_%28mathematical_logic%29) which will be invoked during processing. If the predicate returns `true` then the `:green` node will be next, otherwise the next rule will be evaluated. In this case the next rule says `:red` is the next node with no condition.

### Predicate helpers

* `responded_with(value)` - `value` can be either a string or an array of values
* `variable_matches(varname, value)` - `varname` is a symbol representing the name of the variable to test, `value` can be either a single value or an array
* `response_has_all_of(required_responses)` - only for checkbox questions, true if all of the required responses were checked. `required_responses` can be a single value or an array.
* `response_is_one_of(responses)` -  only for checkbox questions, true if ANY of the responses were checked. `responses` can be a single value or an array.

### Combining predicates

Predicates can be combined using logical conjunctions `|` or `&`:

```ruby
next_node_if(:orange, variable_matches(:first_colour, "red") & variable_matches(:second_colour, "yellow"))
next_node_if(:monochrome, variable_matches(:first_colour, "black") | variable_matches(:second_colour, "white"))
```

### Structuring rules by nesting

Predicates can also be organised by nesting using `on_condition`, e.g.

```ruby
on_condition(responded_with("red")) do
  next_node_if(:orange, variable_matches(:first_color, "yellow"))
  next_node(:red)
end
next_node(:blue)
```

Here's a truth table for the above scenario:

```
|       | Yellow | other
| Red   | orange | red
| other | blue   | blue
```

### Defining named predicates

Named predicates can also be defined using

```ruby
define_predicate(:can_has_cheesburger?) do |response|
  # logic here…
end

next_node_if(:something, can_has_cheesburger?)
```
