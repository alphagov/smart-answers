## Predicate helpers

* `responded_with(value)` - `value` can be either a string or an array of values
* `variable_matches(varname, value)` - `varname` is a symbol representing the name of the variable to test, `value` can be either a single value or an array
* `response_has_all_of(required_responses)` - only for checkbox questions, true if all of the required responses were checked. `required_responses` can be a single value or an array.
* `response_is_one_of(responses)` -  only for checkbox questions, true if ANY of the responses were checked. `responses` can be a single value or an array.

## Combining predicates

Predicates can be combined using logical conjunctions `|` or `&`:

```ruby
next_node_if(:orange, variable_matches(:first_colour, "red") & variable_matches(:second_colour, "yellow"))
next_node_if(:monochrome, variable_matches(:first_colour, "black") | variable_matches(:second_colour, "white"))
```

## Structuring rules by nesting

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

## Defining named predicates

Named predicates can also be defined using

```ruby
define_predicate(:can_has_cheesburger?) do |response|
  # logic here…
end

next_node_if(:something, can_has_cheesburger?)
```
