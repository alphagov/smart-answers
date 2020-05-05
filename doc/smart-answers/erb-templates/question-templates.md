# Question templates

Question templates live in `lib/smart_answer_flows/<flow-name>/questions/<question-name>.govspeak.erb`.

## Content types

The templates can contain content for any of the following keys:

### `:title`

* Valid for all question types
* Default format is `:text`
* Used as the heading (currently "h1")
* [Example](#example) of how it's used

### `:hint`

* Valid for all question types
* Default format is `:text`
* Used as a "hint" paragraph
* [Example](#example) of how it's used

### `:label`

* Valid for value questions
* Default format is `:text`
* Used as a label (preceding the input control)

### `:suffix_label`

* Valid for [value questions](../question-types.md#value_question) & [money questions](../question-types.md#money_question)
* Default format is `:text`
* Used as the label (following the input control)

### `:body`

* Valid for all question types
* Default format is `:govspeak`
* Used to generate the main content (appearing above the input control, e.g. text input element)

### `:post_body`

* Valid for all question types
* Default format is `:govspeak`
* Used to generate supplementary content (appearing below the input control)

### `:error_message`

* Valid for all question types
* Default format is `:text`
* Error message for the default validation error key

### `:error_*`

* Valid for all question types
* Default format is `:text`
* Error message for a custom validation error key
* Any key can be used, but needs to have the `error_` prefix

## Specifying options

This is done using custom syntax, not with the `content_for` block.

### `options(hash)`

* Valid for [multiple choice](../question-types.md#multiple_choice) & [checkbox question](../question-types.md#checkbox_question) types
* `hash` argument is a `Hash` of option keys (strings) and text values (also strings)
* Used to "translate" options keys for multiple choice & checkbox questions into human-friendly text
* [Example](#example) of how it's used with a Flow class


## Example

```ruby
class CheckboxSampleFlow < Flow
  def define
    multiple_choice :how_much_milk_protein? do
      option "0"
      option "2"
      option "12"
    end
  end
end
```

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
