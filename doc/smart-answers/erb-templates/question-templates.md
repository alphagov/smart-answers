# Question templates

Question templates live in `lib/smart_answer_flows/<flow-name>/questions/<question-name>.erb`.

## Content types

The templates can contain content for any of the following keys:

### `:title`

Used as the h1 heading and can only be text. Example:

```erb
<% text_for :title do %>
  How much milk proteins does the product contain?
<% end %>
```

### `:hint`

Used as a "hint" paragraph and can only be text. Example:

```erb
<% text_for :hint do %>
  The values represent % by weight
<% end %>
```

### `:label`

Used as a label (preceding the input control) for value questions. Can only be text. Example:

```erb
<% text_for :label do %>
  Hours per shift
<% end %>
```

Note: As of May 2020 this option may not be working correctly. Please check and amend this documentation.

### `:suffix_label`

Valid for [value questions](../question-types.md#value_question) & [money questions](../question-types.md#money_question). Can only be text. Example:

```erb
<% text_for :suffix_label do %>
  years old
<% end %>
```

### `:body`

Used to generate the main content (appearing above the input control, e.g. text input element).
It is valid for all questions types and can be govspeak or HTML. Example:

```erb
<% govspeak_for :body do %>
  An introduction to a question.
<% end %>
```

### `:post_body`

Used to generate supplementary content (appearing below the input control).
It is valid for all question types and can be govspeak or HTML. Example:

```erb
<% html_for :post_body do %>
  <p>A conclusion to a question</p>
<% end %>
```

### `:error_message`

Error message for the default validation error key. Can only be text. Example:

```erb
<% text_for :error_message do %>
  Try again
<% end %>
```

Note you can specify error messages for a custom validation error key. These
can be specified with a prefix of `:error_`,

Example:

```erb
<% text_for :error_for_a_specific_scenario do %>
  Try again
<% end %>
```

## Specifying options

This is done using a call to the `options` method.

### `options(hash)`

Valid for [multiple choice](../question-types.md#multiple_choice) and [checkbox question](../question-types.md#checkbox_question) types. `hash` argument is a `Hash` of option keys (strings) and text values (also strings).
It is used to "translate" options keys for multiple choice and checkbox questions into human-friendly text.

Example:

```erb
<% options(
  "0": "0-2.49",
  "2": "2.5-11.99",
  "12": "12 or more"
) %>
```
