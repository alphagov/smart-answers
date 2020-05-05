# ERB templates

Content is defined in `content_for` blocks and with the name of the intent of the content:

```erb
<% content_for :title do %>
  Some amazing title
<% end %>
```

The type of content can be explicitly set with the `format:` option:

```erb
<% content_for :title, format: :html do %>
  <h1>Some amazing title</h1>
<% end %>
```

We support Govspeak (`:govspeak`), plain text (`:text`) and HTML (`:html`). See docs for template pages for the default formats of different content blocks.

* [Landing page templates](erb-templates/landing-page-template.md)
* [Question templates](erb-templates/question-templates.md)
* [Outcome templates](erb-templates/outcome-templates.md)

We remove all leading spaces from the content in the `content_for` blocks for Govspeak and Text formats. This allows us to indent the content in the `content_for` blocks without having to worry about it affecting the generated HTML when it's processed using Govspeak.

Any state variable defined in the flow is available to be used in the ERB template. See [storing data](storing-data.md) for the various ways that you can set state variables.
