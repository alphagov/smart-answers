# Question templates

Question templates live in `lib/smart_answer_flows/<flow-name>/questions/<question-name>.govspeak.erb`.

The templates can contain content for the `title`, `hint`, `suffix_label`, `body` and `post_body`, all of which are optional.

The templates can contain the options for multiple choice questions.

## Example

```ruby
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
