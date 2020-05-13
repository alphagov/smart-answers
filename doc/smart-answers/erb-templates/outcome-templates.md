# Outcome templates

Outcome templates live in `lib/smart_answer_flows/<flow-name>/outcomes/<outcome-name>.govspeak.erb`.

## Content types

The templates can contain content for any of the following keys:

### `:title`

* Default format is `:text`
* Used as the heading (currently "h1")

### `:body`

* Default format is `:govspeak`
* Used as the main text

### `next_steps(govspeak)`

* Default format is `:govspeak`
* Used to generate "next steps" content (at top of a right-hand sidebar)

## Example

```erb
<% render_content_for :title do %>
  <% unless calculator.has_commodity_code? %>
    The product composition you indicated is not possible.
  <% else %>
    The Meursing code for a product with this composition is 7<%= calculator.commodity_code %>.
  <% end %>
<% end %>

<% render_content_for :body do %>
  <% if calculator.has_commodity_code? %>
    Use these four digits together with the ten-digit commodity code from Trade Tariff.
  <% end %>
<% end %>
```
