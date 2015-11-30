# Outcome templates

Outcome templates live in `lib/smart_answer_flows/<flow-name>/outcomes/<outcome-name>.govspeak.erb`.

The templates can contain content for the `title`, `body` and `next_steps`, all of which are optional.

## Example

```
<% content_for :title do %>
  <% unless calculator.has_commodity_code? %>
    The product composition you indicated is not possible.
  <% else %>
    The Meursing code for a product with this composition is 7<%= calculator.commodity_code %>.
  <% end %>
<% end %>

<% content_for :body do %>
  <% if calculator.has_commodity_code? %>
    Use these four digits together with the ten-digit commodity code from Trade Tariff.
  <% end %>
<% end %>
```
