# ERB templates

Content is defined using one of three helpers to indicate the format with an argument to indicate the intent:

```erb
<% text_for :title do %>
  This is plain text, any HTML characters used will be espaced. Any indentation is automatically removed.
<% end %>
```

```erb
<% govspeak_for :body do %>
  This uses the GOV.UK markdown dialect, [govspeak](https://github.com/alphagov/govspeak),
  and will be converted to HTML. Any indentation is automatically removed.
<% end %>
```

```erb
<% html_for :body do %>
  <p>This is HTML, used when we need fine grained control over content</p>
<% end %>
```

See the template page documentation for the available contexts and their allowed formats:

* [Landing page templates](erb-templates/landing-page-template.md)
* [Question templates](erb-templates/question-templates.md)
* [Outcome templates](erb-templates/outcome-templates.md)

Any state variable defined in the flow is available to be used in the ERB template. See [storing data](storing-data.md) for the various ways that you can set state variables.
