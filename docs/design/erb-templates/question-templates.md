# Question templates

Question templates live in `app/flows/<flow-name>/questions/<question-name>.erb`.

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

Used as a "hint" paragraph and can be text. For money and radio questions you can
also use govspeak or HTML. Example:

```erb
<% govspeak_for :hint do %>
  Examples of some fruit:

  - apple
  - orange
  - banana
<% end %>
```

### `:caption`

Used as a "caption" paragraph and can only be text. Example:

```erb
<% text_for :caption do %>
  This is a caption
<% end %>
```

If `:caption` is not supplied the `:title` (i.e. the flow name) from the `start_node` is used.

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

Valid for [radio](../question-types.md#radio) and [checkbox](../question-types.md#checkbox_question) question types. `hash` argument is a `Hash` of option keys (strings) and values (strings or hashes).
It is used to specify the human-readable label text or hint text for each of the option keys.

Example with only label text:

```erb
<% options(
  "apple": "Apple",
  "banana": "Bananas",
  "red-grapes": "Red grapes"
) %>
```

Example with label text and hint text:

```erb
<% options(
  "apple": "Apple",
  "gooseberry": {
    label: "Gooseberry",
    hint_text: "These can be sour"
  },
  "red-grapes": "Red grapes"
) %>
```

## Hiding the caption

If you need hide the caption text above the question text. This can be set using the following method:

```erb
<% hide_caption true %>
```

By default the caption is shown (`hide_caption false`).
