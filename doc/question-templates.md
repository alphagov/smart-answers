# Question templates

Question templates live in `lib/smart_answer_flows/<flow-name>/questions/<question-name>.govspeak.erb`.

## Content types

The templates can contain content for any of the following keys:

### `title(text)`

* Valid for all question types
* `text` argument is a String
* Used as the heading (currently "h2")

### `options(hash)`

* Valid for multiple choice & checkbox question types
* `hash` argument is a `Hash` of option key Strings versus option text Strings
* Used to "translate" options keys for multiple choice & checkbox questions into human-friendly text

### `hint(text)`

* Valid for all question types
* `text` argument is a String
* Used as a "hint" paragraph
* Also used to generate a label for value & postcode questions

> I'm not convinced the `hint` key should be overloaded by the value & postcode question types - the `label` key would seem more appropriate.

### `label(text)`

* Valid for value questions
* `text` argument is a String
* Used as a label (preceding the input control)

### `suffix_label(text)`

* Valid for value & money questions
* `text` argument is a String
* Used as the label (following the input control)

### `body(govspeak)`

* Valid for all question types
* `govspeak` argument is a String in [Govspeak][] format
* Used to generate the main content (appearing above the input control)

### `post_body(govspeak)`

* Valid for all question types
* `govspeak` argument is a String in [Govspeak][] format
* Used to generate supplementary content (appearing below the input control)

### `error_message(message)`

* Valid for all question types
* `message` argument is a String
* Error message for the default validation error key

### `error_xxx(message)`

* Valid for all question types
* `message` argument is a String
* Error message for a custom validation error key
* Any key can be used, but by convention the `error_` prefix is used

## Example

```erb
<% content_for :title do %>
  How much milk proteins does the product contain?
<% end %>

<% options(
  "0": "0-2.49",
  "2": "2.5-11.99",
  "12": "12 or more"
) %>

<% content_for :hint do %>
  The values represent % by weight
<% end %>
```

[Govspeak]: https://github.com/alphagov/govspeak
