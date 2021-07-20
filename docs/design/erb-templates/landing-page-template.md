# Landing page template

Landing page templates live in `app/flows/<flow-name>/start.erb`.

## Content types

The templates can contain content for any of the following keys:

### `:title`

Used as the h1 heading and can only be text. Example:

```erb
<% text_for :title do %>
  Look up Meursing code
<% end %>
```

### `:meta_description`

Used as the content for the [meta description tag][meta-description]. Can only be text. Example:

```erb
<% text_for :meta_description do %>
  Look up the additional code (Meursing code) required for import or export of goods containing certain types of milk and sugars
<% end %>
```

### `:body`

Used to generate the main content (appearing above the start button). Expected to be govspeak or HTML. Example:

```erb
<% govspeak_for :body do %>
  Use this tool to look up the additional code (Meursing code) for import or export of goods containing certain types of milk and sugars covered Regulation (EC) No. 1216/09.
<% end %>
```

```erb
<% html_for :body do %>
  <p>Use this tool to look up the additional code (Meursing code) for import or export of goods containing certain types of milk and sugars covered Regulation (EC) No. 1216/09.</p>
<% end %>
```
### `:post_body`

Used to generate supplementary content (appearing below the start button). Expected to be govspeak or HTML. Example:

```erb
<% govspeak_for :post_body do %>
  Code of measuring practice became globally effective in May 2015.
<% end %>
```

[meta-description]: https://moz.com/learn/seo/meta-description
