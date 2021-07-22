# Outcome templates

Outcome templates live in `app/flows/<flow-name>/outcomes/<outcome-name>.erb`.

## Content types

The templates can contain content for any of the following keys:

### `:title`

Used as the h1 heading and can only be text. Example:

```erb
<% text_for :title do %>
  <% unless calculator.has_commodity_code? %>
    The product composition you indicated is not possible.
  <% else %>
    The Meursing code for a product with this composition is 7<%= calculator.commodity_code %>.
  <% end %>
<% end %>
```

### `:body`

Used to generate the main content. Expected to be govspeak or HTML. Example:

```erb
<% govspeak_for :body do %>
  <% if calculator.has_commodity_code? %>
    Use these four digits together with the ten-digit commodity code from Trade Tariff.
  <% end %>
<% end %>
```

### `:use_title_as_h1`

When `true`, specifies that you want to use the given `title` as the outcome page
`<h1>` heading instead of the default `<h2>` heading.  The flow title is no longer
shown.

```erb
<% use_title_as_h1 true %>
```

### `next_steps`

Used to generate the "next steps" content (at the top of the right-hand sidebar). Expected to be govspeak or HTML. Example:

```erb
<% govspeak_for :next_steps do %>
  Find out what happens to [ownerless property](/unclaimed-estates-bona-vacantia "Ownerless property (bona vacantia)")
<% end %>
```
